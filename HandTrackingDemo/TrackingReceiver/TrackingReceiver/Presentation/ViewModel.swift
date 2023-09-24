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
	var glove: Entity?
	var anchor: AnchorEntity?

    private var contentEntity = Entity()

	func setupContentEntity() -> Entity {
		setupObjects()
		return contentEntity
	}

	func setupObjects() {
		let width: Float = 0.3
		let thickness: Float = 0.005
		glove = ModelEntity(mesh: .generateBox(width: width, height: width, depth: thickness), materials: [SimpleMaterial(color: UIColor(.red), isMetallic: false)])
		ball = ModelEntity(mesh: .generateSphere(radius: 0.03), materials: [SimpleMaterial(color: UIColor(.white), isMetallic: true)])
		thumbTip = ball?.clone(recursive: true)
		littleTip = ball?.clone(recursive: true)
		wristTip = ball?.clone(recursive: true)
		
		glove?.position = SIMD3(x: 0, y: 1.2, z: -2.2)
		thumbTip?.position = SIMD3(x: 0, y: 1.2, z: -2.2)
		littleTip?.position = SIMD3(x: 0, y: 1.2, z: -2.2)
		wristTip?.position = SIMD3(x: 0, y: 1.7, z: -2.2)

		contentEntity.addChild(glove!)
		contentEntity.addChild(thumbTip!)
		contentEntity.addChild(littleTip!)
		contentEntity.addChild(wristTip!)
	}
	
	func setPoints(_ point: [SIMD3<Scalar>?]) {
		guard let b = thumbTip else { return }
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
	
	func addPoint4(_ mtx4: simd_float4x4) {
		guard let b = ball else { return }
		let ent = b.clone(recursive: true)

		ent.transform = Transform(matrix: mtx4)
		ent.scale = [1, 1, 1]
		contentEntity.addChild(ent)
	}
	
	func moveGlove(_ mtx4: simd_float4x4) {
		glove?.transform = Transform(matrix: mtx4)
		glove?.scale = [1, 1, 1]
	}
}
