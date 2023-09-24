//
//  HandModel.swift
//    Display hand joints in visionOS simulator
//
//  Copyright © 2023 Yos. All rights reserved.
//

import Foundation
import Observation
import RealityKit
import RealityKitContent
import ARKit
import SceneKit

@Observable
class HandModel {
	var ball: Entity?
	private var handJoints: [[[SIMD3<Scalar>?]]] = []			// array of fingers of both hand (0:right hand, 1:left hand)
	private var lastHandCount = 0
	private var fingerObj: [[[ModelEntity?]]] = [
			[
				[nil,nil,nil,nil],
				[nil,nil,nil,nil],
				[nil,nil,nil,nil],
				[nil,nil,nil,nil],
				[nil,nil,nil,nil],
				[nil]
			],
			[
				[nil,nil,nil,nil],
				[nil,nil,nil,nil],
				[nil,nil,nil,nil],
				[nil,nil,nil,nil],
				[nil,nil,nil,nil],
				[nil]
			]
		]
    private var contentEntity = Entity()

	func setupContentEntity() -> Entity {
		return contentEntity
	}

	func setHandJoints(left: [[SIMD3<Scalar>?]]?, right: [[SIMD3<Scalar>?]]?) {
		handJoints = []
		if let r=right, r.count>0 {
			handJoints.append(r)
		}
		else {
			handJoints.append([])
		}
		if let l=left, l.count>0 {
			handJoints.append(l)
		}
		else {
			handJoints.append([])
		}
	}
	
	func showFingers() {
		checkFingers()
		guard handJoints.count>0 else { return }

		for handNo in 0...1 {
			guard handNo<handJoints.count ,handJoints[handNo].count > 0 else { continue }
			for fingerNo in 0...5 {
				for jointNo in 0...2 {
					if fingerNo == 5 && jointNo > 0 { continue }
					var sp = handJoints[handNo][fingerNo][jointNo]
					var ep = handJoints[handNo][fingerNo][jointNo]
					if !(fingerNo == 5 && jointNo == 0) {
						ep = handJoints[handNo][fingerNo][jointNo+1]
					}
					drawBoneBetween(handNo: handNo, fingerNo: fingerNo, jointNo: jointNo, startPoint: sp, endPoint: ep)
				}
			}
		}
	}
	
	func checkFingers() {
		if handJoints.count == lastHandCount { return }

		for handNo in 0...1 {
			for fingerNo in 0...5 {
				for jointNo in 0...2 {
					if fingerNo == 5 && jointNo > 0 { continue }
					
					let rectangle:ModelEntity? = fingerObj[handNo][fingerNo][jointNo]
					if rectangle == nil {
						rectangle?.isEnabled = false
						continue
					}
					rectangle?.isEnabled = true
				}
			}
		}
		
		lastHandCount = handJoints.count
	}
	
	func drawBoneBetween(handNo: Int, fingerNo: Int, jointNo: Int,  startPoint: SIMD3<Scalar>?, endPoint: SIMD3<Scalar>?) {
		guard let sp = startPoint, let ep = endPoint else { return }
		guard fingerNo<=5 && jointNo < 3 else { return }
		guard fingerObj.count > 0 else { return }

		let boneThickness:Float = 0.025
		var size:Float = distance(sp, ep)
		if size == 0.0 {
			size = boneThickness
		}

		if let rectangle:ModelEntity = fingerObj[handNo][fingerNo][jointNo] {
			rectangle.isEnabled = true
			let middlePoint = SIMD3(x: (sp.x + ep.x)/2, y: (sp.y + ep.y)/2, z: (sp.z + ep.z)/2)
			rectangle.setPosition(middlePoint, relativeTo: nil)
						if handTrackFake.enableFake {
				rectangle.setScale(SIMD3(x: 0.5, y: 0.5, z: size*50) , relativeTo: contentEntity)
			}
			else {
				rectangle.setScale(SIMD3(x: 0.5, y: 0.5, z: 1.0) , relativeTo: contentEntity)
			}
			rectangle.look(at: sp, from: middlePoint, relativeTo: nil)
		}
	}
	
	func setupBones() {
		for handNo in 0...1 {
			for fingerNo in 0...5 {
				for jointNo in 0...2 {
					if fingerNo == 5 && jointNo > 0 { continue }
					
					let boneThickness:Float = 0.025
					let rectangle = ModelEntity(mesh: .generateBox(size: SIMD3(x: boneThickness, y: boneThickness, z: boneThickness) ))
					rectangle.physicsBody = PhysicsBodyComponent(massProperties:  .init(mass: 10.0), material: .generate(friction: 0.1, restitution: 0.1), mode: .kinematic)
					rectangle.generateCollisionShapes(recursive: false)

					contentEntity.addChild(rectangle)
					rectangle.isEnabled = false
					fingerObj[handNo][fingerNo][jointNo] = rectangle
				}
			}
		}
	}
}
