//
//  ImmersiveView.swift
//
//  Copyright © 2023 Yos. All rights reserved.
//

import SwiftUI
import ARKit
import RealityKit
import RealityKitContent
import SceneKit
import MultipeerConnectivity

var gestureAloha: Gesture_Aloha?
var gestureDraw: Gesture_Draw?

struct ImmersiveView: View {
	let handTrackProcess: HandTrackProcess = HandTrackProcess()
	let hand = Hand()
	let handModel = HandModel()
	let viewModel = ViewModel()
	@State var logText: String = "Ready..."
	var worldAnchor: AnchorEntity?

	init(){
		textLog("init")
		handTrackFake.initAsBrowser()
		worldAnchor = AnchorEntity(world: [0,0,0])
	}
	var body: some View {
		ZStack {
			RealityView { content in
				if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
					scene.position = SIMD3(x: 0, y: 0.4, z: -1.5)
					content.add(scene)
				}
				if let hands = try? await Entity(named: "hands", in: realityKitContentBundle) {
//					hands.position = SIMD3(x: 0, y: 0.4, z: -1.5)
					let leftHand = hands.findEntity(named: "LeftHand")
					let rightHand = hands.findEntity(named: "RightHand")
					hand.setHandEntity(leftHand: leftHand!, rightHand: rightHand!)
					let handEntify = hand.setupContentEntity()
					content.add(handEntify)
				}
				let handEntity = handModel.setupContentEntity()
				content.add(handEntity)
				handModel.setupBones()
				let modelEntity = viewModel.setupContentEntity()
				content.add(modelEntity)
			}
			RealityView { content, attachments in
				let ent = Entity()
				ent.scale = [4.0, 4.0, 4.0]
				ent.position = SIMD3(x: 0, y: 1.5, z: -2)
				ent.generateCollisionShapes(recursive: true)
				content.add(ent)
				if let textAttachement = attachments.entity(for: "text_view") {
					textAttachement.position = SIMD3(x: 0, y: 0, z: 0)
					ent.addChild(textAttachement)
				}
			} attachments: {
				Attachment(id: "text_view") {
					Text(logText)
						.frame(width: 1000, height: 690, alignment: .topLeading)
						.multilineTextAlignment(.leading)
						.background(Color.blue)
						.foregroundColor(Color.white)
				}
			}
//			RealityView { content in
//				let handEntity = handModel.setupContentEntity()
//				content.add(handEntity)
//				handModel.setupBones()
//				let modelEntity = viewModel.setupContentEntity()
//				content.add(modelEntity)
//			}
		}	// ZStack
		.task {
			await handTrackProcess.handTrackingStart()
			gestureDraw = Gesture_Draw(delegate: self)
			gestureAloha = Gesture_Aloha(delegate: self)
		}
		.task {
			textLog("publishHandTrackingUpdates")
			// Hand tracking loop
			await handTrackProcess.publishHandTrackingUpdates(updateJob: { (fingerJoints, updates) -> Void in
				DispatchQueue.main.async {
					if handTrackFake.enableFake == true {
						displayHandJoints(handJoints: fingerJoints)
					}
					else {
						do {
//							if (handTrackProcess.handAnchorUpdate != nil) {
							hand.show(anchorUpdate:updates!)
//							}
						} catch {
							NSLog("Error")
						}

					}
					gestureDraw?.checkGesture(handJoints: fingerJoints)
				}
			})
		}
		.task {
			await handTrackProcess.monitorSessionEvents()
		}
	}
	
	// Display hand tracking
	static var lastState = MCSessionState.notConnected
	func displayHandJoints(handJoints: [[[SIMD3<Scalar>?]]]) {
		let nowState = handTrackFake.sessionState
		if nowState != ImmersiveView.lastState {
			switch nowState {
			case .connected:
				textLog("HandTrackFake connected.")
			case .connecting:
				textLog("HandTrackFake connecting...")
			default:
				textLog("HandTrackFake not connected.")
			}
			ImmersiveView.lastState = nowState
		}

		switch handJoints.count {
		case 1:
			handModel.setHandJoints(left : handJoints[0], right: nil)
			handModel.showFingers()
		case 2:
			handModel.setHandJoints(left : handJoints[0], right: handJoints[1])
			handModel.showFingers()
		default:
			handModel.setHandJoints(left : nil, right: nil)
			handModel.showFingers()
		}
		if HandTrackProcess.handJoints.count < 2 {
			HandTrackProcess.handJoints.append([])
		}
	}
}

// MARK: Gesture delegate job

extension ImmersiveView: GestureDelegate {

	func gesture(gesture: GestureBase, event: GestureDelegateEvent) {
		if gesture is Gesture_Aloha {
			handle_gestureAloha(event: event)
		}
		if gesture is Gesture_Draw {
			handle_gestureDraw(event: event)
		}
	}
	
	// Draw
	func handle_gestureDraw(event: GestureDelegateEvent) {
		switch event.type {
		case .Moved3D:
			if let pnt = event.location[0] as? SIMD3<Scalar> {
				viewModel.addPoint(pnt)
			}
		case .Fired:
			// clear canvas
			break
		case .Moved2D:
			break
		case .Began:
			break
		case .Ended:
			break
		case .Canceled:
			break
		default:
			break
		}
	}
	// Aloha
	func handle_gestureAloha(event: GestureDelegateEvent) {
		switch event.type {
		case .Moved3D:
			viewModel.setPoints(event.location as! [SIMD3<Scalar>?])
		case .Fired:
			if let pnt = event.location[0] as? SIMD3<Scalar> {
				viewModel.addPoint(pnt)
			}
			break
		case .Moved2D:
			break
		case .Began:
			break
		case .Ended:
			break
		case .Canceled:
			break
		default:
			break
		}
	}
}

// MARK: Other job

extension ImmersiveView {

	func textLog(_ message: String) {
		DispatchQueue.main.async {
			logText = message+"\r"+logText
		}
	}

	func triangleCenterWithAxis(joint1:SIMD3<Scalar>?, joint2:SIMD3<Scalar>?, joint3:SIMD3<Scalar>?) -> simd_float4x4? {
		guard
			let j1 = joint1,
			let j2 = joint2,
			let j3 = joint3
		else {
			return nil
		}
		// center of triangle
		let h1 = (j1+j2) / 2	// half point of j1 & j2
		let ct = (h1+j3) / 2	// center point (half point of h1 & j3)

		let xAxis = normalize(j2 - j1)
		let yAxis = normalize(j3 - h1)
		let zAxis = normalize(cross(xAxis, yAxis))

		let triangleCenterWorldTransform = simd_matrix(
			SIMD4(xAxis.x, xAxis.y, xAxis.z, 0),
			SIMD4(yAxis.x, yAxis.y, yAxis.z, 0),
			SIMD4(zAxis.x, zAxis.y, zAxis.z, 0),
			SIMD4(ct.x, ct.y, ct.z, 1)
		)
		return triangleCenterWorldTransform
	}
}

// MARK: Preview

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
