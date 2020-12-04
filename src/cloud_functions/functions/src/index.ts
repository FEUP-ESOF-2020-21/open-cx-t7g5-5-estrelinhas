import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
admin.initializeApp()

import { FieldPath, FieldValue } from '@google-cloud/firestore'

const tools = require('firebase-tools');


const db = admin.firestore()

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//

exports.getTop20 = functions.https.onCall(async (data, context) => {
    const profilesRef = db.collection("conference").doc(data.conferenceID).collection("profiles")
    const userRef = profilesRef.doc(data.profileID)
    const userLikesRef = userRef.collection("likes")

    const matchesQuery = await userLikesRef.where("match", "==", true).get()
    let matches : Array<String> = [];
    matchesQuery.forEach(element => {
        matches.push(element.id)
    });
    
    const userInterestsQuery = await userRef.get()
    const userInterestsData = userInterestsQuery.data()
    let interests : Array<String> = [];
    interests = userInterestsData? userInterestsData["interests"] : [];
    
    let top : Array<Array<String>> = []
    if (interests && interests.length > 0) {
        const profilesQuery = await profilesRef.where(FieldPath.documentId(), "!=", data.profileID).where("interests", "array-contains-any", interests).get()
        profilesQuery.forEach(profile => {
            if (!matches.includes(profile.id)) {
                let profile_int = profile.data()["interests"]
                const common = profile_int.filter((interest : String) => interests.includes(interest))
                if (common.length > 0) {
                    top.push([profile.id, common.length])
                }
            }
        })
    }

    top.sort((a, b) => {return +b[1] - +a[1]})

    return top.slice(0, 5);
});

/**
 * Function that recursively deletes documents and subcollections of a conference or profile.
 * Also cascades to delete storage files.
 * 
 * data.conferenceID - conference ID to delete or to which profile to delete belongs
 * data.profileID - profile ID to delete
 * data.type - delete conference or profile
 */
exports.deleteConferenceOrProfile = functions.https.onCall(async (data, context) => {
    const conferencePath = "/conference/" + data.conferenceID
    const conferenceRef = db.doc(conferencePath)
    const conferenceData = (await conferenceRef.get()).data()
    const creator_uid = conferenceData? conferenceData["uid"] : null

    if (!creator_uid) {
        throw new functions.https.HttpsError(
            'internal',
            'Could not retrieve creator UID from conference. Possibly does not exist.'
        )
    }

    if (data.type === "conference") {
        if (creator_uid !== context.auth?.uid) {
            throw new functions.https.HttpsError(
                'permission-denied',
                'Only conference creator can delete conference'
            )
        }

        await tools.firestore.delete(conferencePath, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
        })

        return "Deleted documents and files for conference " + data.conferenceID
    }
    else if (data.type === "profile") {
        const profilePath = conferencePath + "/profiles/" + data.profileID
        const profileRef = db.doc(profilePath)
        const profileData = (await profileRef.get()).data()
        if (!profileData) {
            throw new functions.https.HttpsError(
                'internal',
                'Could not retrieve profile. Possibly does not exist.'
            )
        }

        if (data.profileID !== context.auth?.uid && creator_uid !== context.auth?.uid) {
            throw new functions.https.HttpsError(
                'permission-denied',
                'Only profile or conference creator can delete profile'
            )
        }

        await tools.firestore.delete(profilePath, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
        })

        return "Deleted documents and files for profile " + data.profileID + " in conference " + data.conferenceID
    }
    else {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'Can only delete conference or profile entries'
        )
    }
});

exports.editInterests = functions.firestore.document('conference/{confID}').onUpdate(async (change, context) => {
    const oldConf = change.before.data()
    const oldInterests : Array<String>  = oldConf.interests
    const newConf = change.after.data()
    const newInterests : Array<String> = newConf.interests

    const deletedInterests = oldInterests.filter(interest => !newInterests.includes(interest))

    if (deletedInterests.length > 0) {
        const profiles = db.collection("conference").doc(change.after.id).collection("profiles")

        let batches : Array<Array<String>> = []
        let idx = 0

        while (idx < deletedInterests.length) {
            batches.push(deletedInterests.slice(idx, idx + 10))
            idx += 10
        }

        for (let batch of batches) {
            const hadInterest = await profiles.where("interests", "array-contains-any", batch).get()

            hadInterest.forEach((profile) => {
                profiles.doc(profile.id).update({
                    interests: FieldValue.arrayRemove(...batch),
                }).catch((err) => console.log(err))
            })
        }
    }
});

exports.onDeleteConference = functions.firestore.document('conference/{confID}').onDelete((change, context) => {
    const bucket = admin.storage().bucket();

    bucket.deleteFiles({
        prefix: 'conferences/' + context.params.confID,
    }, function(err) {
        if (err)
            console.log(err)
    },)
});

exports.onDeleteProfile = functions.firestore.document('conference/{confID}/profiles/{profileID}').onDelete(async (change, context) => {
    const bucket = admin.storage().bucket();

    bucket.deleteFiles({
        prefix: 'conferences/' + context.params.confID + "/profiles/" + context.params.profileID,
    }, function(err) {
        if (err)
            console.log(err)
    },)

    const liked_profiles = await db.collectionGroup("likes")
        .where("conference_id", "==", context.params.confID)
        .where("uid", "==", context.params.profileID)
        .get()
    
    
    liked_profiles.forEach(profile => {
        profile.ref.delete().catch((err) => console.log(err))
    });
});
