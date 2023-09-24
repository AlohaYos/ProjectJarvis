//
//  HandTrackProcess.swift
//    Manage real/fake hand tracking and make joints array (HandTrackProcess.handJoints)
//
//  Copyright © 2023 Yos. All rights reserved.
//

import Foundation
import CoreGraphics
import SwiftUI
import Vision
import ARKit

class HandTrackProcess {

	enum WhichHand: Int {
		case right = 0
		case left  = 1
	}
	enum WhichFinger: Int {
		case thumb  = 0
		case index
		case middle
		case ring
		case little
		case wrist
	}
	enum WhichJoint: Int {
		case tip = 0	// finger top
		case dip = 1	// first joint
		case pip = 2	// second joint
		case mcp = 3	// third joint
	}
	enum WhichJointNo: Int {
		case top = 0	// finger top
		case first = 1	// first joint
		case second = 2	// second joint
		case third = 3	// third joint
	}
	static let wristJointIndex = 0

	// Real HandTracking (not Fake)
	let session = ARKitSession()
	var handTracking = HandTrackingProvider()
	static var handJoints: [[[SIMD3<Scalar>?]]] = []			// array of fingers of both hand (0:right hand, 1:left hand)

	func handTrackingStart() async {
		if handTrackFake.enableFake == false {
			do {
				var auths = HandTrackingProvider.requiredAuthorizations
				if HandTrackingProvider.isSupported {
					print("ARKitSession starting.")
					try await session.run([handTracking])
				}
			} catch {
				print("ARKitSession error:", error)
			}
		}
	}

	// Hand tracking loop
	func publishHandTrackingUpdates(updateJob: @escaping(([[[SIMD3<Scalar>?]]]) -> Void)) async {

		// Fake HandTracking
		if handTrackFake.enableFake {
			DispatchQueue.main.async {
				Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
					let dt = handTrackFake.receiveHandTrackData()
					HandTrackProcess.handJoints = dt
					// CALLBACK
					updateJob(dt)
				}
			}
		}
		// Real HandTracking
		else {
			for await update in handTracking.anchorUpdates {
				var rightAnchor: HandAnchor?
				var leftAnchor:  HandAnchor?
				var fingerJoints1 = [[SIMD3<Scalar>?]]()
				var fingerJoints2 = [[SIMD3<Scalar>?]]()

				switch update.event {
				case .updated:
					let anchor = update.anchor
					guard anchor.isTracked else { continue }
					
					if anchor.chirality == .left {
						leftAnchor = anchor
						saveHandAnchorData(anchor: anchor, whichHand: 1)
					} else if anchor.chirality == .right {
						rightAnchor = anchor
						saveHandAnchorData(anchor: anchor, whichHand: 0)
					}
				default:
					break
				}
				
				do {
					if rightAnchor != nil && leftAnchor != nil {
						fingerJoints1 = try getFingerJoints(with: rightAnchor)
						fingerJoints2 = try getFingerJoints(with: leftAnchor)
					}
					else {
						if rightAnchor != nil {
							fingerJoints1 = try getFingerJoints(with: rightAnchor)
							fingerJoints2 = []
						}
						if leftAnchor != nil {
							fingerJoints2 = try getFingerJoints(with: leftAnchor)
							fingerJoints1 = []
						}
					}
				} catch {
					NSLog("Error")
				}
				
				if rightAnchor != nil || leftAnchor != nil {
					HandTrackProcess.handJoints = [fingerJoints1, fingerJoints2]
					// CALLBACK
					updateJob([fingerJoints1, fingerJoints2])
				}
			}
		}
	}
	
	func monitorSessionEvents() async {
		if handTrackFake.enableFake == false {
			for await event in session.events {
				switch event {
				case .authorizationChanged(let type, let status):
					if type == .handTracking && status != .allowed {
						// Stop, ask the user to grant hand tracking authorization again in Settings.
					}
				@unknown default:
					print("Session event \(event)")
					break
				}
			}
		}
	}
	
	func cv(a: HandAnchor, j: HandSkeleton.JointName) -> SIMD3<Scalar>? {
		guard let sk = a.handSkeleton else { return [] }
		let valSIMD4 = matrix_multiply(a.originFromAnchorTransform, sk.joint(j).anchorFromJointTransform).columns.3
		return valSIMD4[SIMD3(0, 1, 2)]
	}
	
	// get finger joint position array (VisionKit coordinate)
	func getFingerJoints(with anchor: HandAnchor?) throws -> [[SIMD3<Scalar>?]] {
		do {
			guard let ac = anchor else { return [] }
			let fingerJoints: [[SIMD3<Scalar>?]] =
			[
				[cv(a:ac,j:.thumbTip),cv(a:ac,j:.thumbIntermediateTip),cv(a:ac,j:.thumbIntermediateBase),cv(a:ac,j:.thumbKnuckle)],
				[cv(a:ac,j:.indexFingerTip),cv(a:ac,j:.indexFingerIntermediateTip),cv(a:ac,j:.indexFingerIntermediateBase),cv(a:ac,j:.indexFingerKnuckle)],
				[cv(a:ac,j:.middleFingerTip),cv(a:ac,j:.middleFingerIntermediateTip),cv(a:ac,j:.middleFingerIntermediateBase),cv(a:ac,j:.middleFingerKnuckle)],
				[cv(a:ac,j:.ringFingerTip),cv(a:ac,j:.ringFingerIntermediateTip),cv(a:ac,j:.ringFingerIntermediateBase),cv(a:ac,j:.ringFingerKnuckle)],
				[cv(a:ac,j:.littleFingerTip),cv(a:ac,j:.littleFingerIntermediateTip),cv(a:ac,j:.littleFingerIntermediateBase),cv(a:ac,j:.littleFingerKnuckle)],
				[cv(a:ac,j:.wrist)]
			]
			return fingerJoints
		} catch {
			NSLog("Error")
		}
		return []
	}

	// MARK: Save HandAnchor data
	struct PosCell: Encodable {	// 1 line
		var x: Float
		var y: Float
		var z: Float
		var w: Float
	}
	struct JointSIMD4: Encodable {	// 4 lines in one joint
		var matrix: Array<PosCell>
	}
	struct HandAnchorJson: Encodable {
		var chirality:String
		var wristTransform:JointSIMD4
		var joints:[JointSIMD4]	// all joints in one hand
	}

	func saveHandAnchorData(anchor: HandAnchor?, whichHand:Int /* right=0, left=1 */) {
		
		guard let ac = anchor else { return }

		if let joints = ac.handSkeleton?.allJoints {
			var jd: [JointSIMD4] = []
			let chirality: HandAnchor.Chirality = ac.chirality
			let wristTransform: simd_float4x4 = ac.originFromAnchorTransform
			let cell0 = PosCell(x: wristTransform.columns.0.x,
								y: wristTransform.columns.0.y,
								z: wristTransform.columns.0.z,
								w: wristTransform.columns.0.w)
			let cell1 = PosCell(x: wristTransform.columns.1.x,
								y: wristTransform.columns.1.y,
								z: wristTransform.columns.1.z,
								w: wristTransform.columns.1.w)
			let cell2 = PosCell(x: wristTransform.columns.2.x,
								y: wristTransform.columns.2.y,
								z: wristTransform.columns.2.z,
								w: wristTransform.columns.2.w)
			let cell3 = PosCell(x: wristTransform.columns.3.x,
								y: wristTransform.columns.3.y,
								z: wristTransform.columns.3.z,
								w: wristTransform.columns.3.w)

			for index in 0...joints.count-1 {
				let val = joints[index].anchorFromJointTransform
				let cell0 = PosCell(x: val.columns.0.x,
									y: val.columns.0.y,
									z: val.columns.0.z,
									w: val.columns.0.w)
				let cell1 = PosCell(x: val.columns.1.x,
									y: val.columns.1.y,
									z: val.columns.1.z,
									w: val.columns.1.w)
				let cell2 = PosCell(x: val.columns.2.x,
									y: val.columns.2.y,
									z: val.columns.2.z,
									w: val.columns.2.w)
				let cell3 = PosCell(x: val.columns.3.x,
									y: val.columns.3.y,
									z: val.columns.3.z,
									w: val.columns.3.w)
				let oneJoint = JointSIMD4(matrix: [cell0, cell1, cell2, cell3])	// one joint
				jd.append(oneJoint)
			}
			// save to file
			let wt = JointSIMD4(matrix: [cell0, cell1, cell2, cell3])

			let jsonData = HandAnchorJson(chirality: chirality.description,
										  wristTransform: wt,
										  joints: jd)
			// encode & print to console
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			do {
				let data = try encoder.encode(jsonData)
				NSLog(String(data: data , encoding: .utf8)!)
			} catch {
				NSLog("Error")
			}
		}
	}
}

