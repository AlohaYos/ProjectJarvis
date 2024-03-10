//
//  ViewModel.swift
//    Display objects in visionOS simulator
//
//  Copyright © 2023 Yos. All rights reserved.
//

import RealityKit
import Observation

import RealityKitContent
import Foundation
import ARKit
import SceneKit

@Observable
class ViewModel {
	var ball: Entity?
	var thumbTip: Entity?
	var littleTip: Entity?
	var wristTip: Entity?
//	var glove: Entity?
//	var anchor: AnchorEntity?

//	var cue: Entity?
//	let cueLength:Float = 1.47		// 147cm (58inch)
//	let cueGripLength:Float = 0.60	// meters
//	let cueGripLength:Float = 0.40	// meters

	private var contentEntity = Entity()
	
	func setupContentEntity() -> Entity {
		setupObjects()
//		ball = ModelEntity(mesh: .generateSphere(radius: 0.03), materials: [SimpleMaterial(color: UIColor(.white), isMetallic: true)])
		return contentEntity
	}
	
	func setupObjects() {
//		let width: Float = 0.3
//		let thickness: Float = 0.005
//		let cueRadius: Float = 0.02
//		glove = ModelEntity(mesh: .generateBox(width: width, height: width, depth: thickness), materials: [SimpleMaterial(color: UIColor(.red), isMetallic: false)])
		ball = ModelEntity(mesh: .generateSphere(radius: 0.03), materials: [SimpleMaterial(color: UIColor(.red), isMetallic: false)])
		thumbTip = ball?.clone(recursive: true)
		littleTip = ball?.clone(recursive: true)
		wristTip = ball?.clone(recursive: true)

//		glove?.position = SIMD3(x: 0, y: 1.2, z: -3.5)
		thumbTip?.position = SIMD3(x: 0, y: 1.2, z: -3.5)
		littleTip?.position = SIMD3(x: 0, y: 1.2, z: -3.5)
		wristTip?.position = SIMD3(x: 0, y: 1.7, z: -3.5)
		
//		contentEntity.addChild(glove!)
		contentEntity.addChild(thumbTip!)
		contentEntity.addChild(littleTip!)
		contentEntity.addChild(wristTip!)
		
//		glove?.isEnabled = false
		thumbTip?.isEnabled = false
		littleTip?.isEnabled = false
		wristTip?.isEnabled = false
	}
	
//	func setCueEntiry(_ ent: Entity?) {
//		cue = ent
//		cue?.generateCollisionShapes(recursive: true)
//		contentEntity.addChild(cue!)
//	}

	func setPoints(_ point: [SIMD3<Scalar>?]) {
		guard thumbTip != nil else { return }
		guard point.count >= 3 else { return }
		guard let thumbPos = point[0], let littlePos = point[1], let wristPos = point[2] else { return }
		
		thumbTip?.position = thumbPos
		wristTip?.position = wristPos
		littleTip?.position = littlePos
		thumbTip?.scale = [1, 1, 1]
		wristTip?.scale = [1, 1, 1]
		littleTip?.scale = [1, 1, 1]
	}
	
	func addPoint(_ point: SIMD3<Scalar>) {
		guard let b = ball else { return }
		let ent = b.clone(recursive: true)
		ent.scale = [0.3, 0.3, 0.3]
		ent.position = SIMD3(x: point.x, y: point.y, z: point.z)
		contentEntity.addChild(ent)
	}
	
//	func addPoint4(_ mtx4: simd_float4x4) {
//		guard let b = ball else { return }
//		let ent = b.clone(recursive: true)
//		
//		ent.transform = Transform(matrix: mtx4)
//		ent.scale = [1, 1, 1]
//		contentEntity.addChild(ent)
//	}
	
//	func moveGlove(_ mtx4: simd_float4x4) {
//		glove?.transform = Transform(matrix: mtx4)
//		glove?.scale = [1, 1, 1]
//	}
//	
//	func moveCue(_ mtx4: simd_float4x4) {
//		hideCue(false)
//		cue?.transform = Transform(matrix: mtx4)
//		cue?.scale = [1, 1, 1]
//	}
//	
//	func moveCue(_ point: [SIMD3<Scalar>?]) {
//		guard point.count >= 2 else { return }
//		guard let pickPos = point[0], let grabCenter = point[1] else { return }
//
////		print("POS \(point.debugDescription)")
//		
//		hideCue(false)
////		cue?.setScale(SIMD3(x: 1, y: 1, z: 1) , relativeTo: contentEntity)
//		let v = SIMD3(pickPos.x-grabCenter.x, pickPos.y-grabCenter.y, pickPos.z-grabCenter.z)
//		let len = sqrt(v.x*v.x+v.y*v.y+v.z*v.z)
//		let ratio = (cueLength / 2.0 - cueGripLength) / len
//		let vout = SIMD3(v.x*ratio, v.y*ratio, v.z*ratio)
//		let middlePoint = SIMD3(x: grabCenter.x+vout.x, y: grabCenter.y+vout.y, z: grabCenter.z+vout.z)
//		cue?.setPosition(middlePoint, relativeTo: nil)
//		cue?.look(at: grabCenter, from: middlePoint, relativeTo: nil)
//	}
//	
//	func hideCue(_ flag:Bool) {
//		cue?.isEnabled = !flag
//		cue?.stopAllAudio()
//		
////		if flag {
////			cue?.setScale(SIMD3(x: 0, y: 0, z: 0) , relativeTo: contentEntity)
////		}
////		else {
////			cue?.setScale(SIMD3(x: 1, y: 1, z: 1) , relativeTo: contentEntity)
////		}
//	}
}

