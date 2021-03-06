Class {
	#name : #MEDMaContainerComponent,
	#superclass : #MAContainerComponent,
	#traits : 'TWEBComponentHelpers',
	#classTraits : 'TWEBComponentHelpers classTrait',
	#instVars : [
		'superComponent',
		'formDecoration'
	],
	#category : #'Mediaclue-Magritte'
}

{ #category : #private }
MEDMaContainerComponent >> buildChildren [
	"Wir benötigen alle, auch die invisible, weil wir gezielt Komponenten rauspicken
	beim rendern, und nicht automatisiert alle rendern"
	^ self magritteDescription
		inject: Dictionary new
		into: [ :result :each |
			result at: each put: (each componentClass
				memento: self memento description: each parent: self).
			result ]
]

{ #category : #'as yet unclassified' }
MEDMaContainerComponent >> formDecoration [
	^formDecoration
]

{ #category : #'as yet unclassified' }
MEDMaContainerComponent >> formDecoration: anObject [
	formDecoration := anObject
]

{ #category : #rendering }
MEDMaContainerComponent >> renderContentOn: html [
"	self magritteDescription componentRenderer
		component: self on: html"
	"html ist ein magrittified canvas"
	
	"OPTIMIZE: Etwas overkill jedesmal zu setzen, aber wo sonst?"
	html maContainerComponent: self.
	
	superComponent renderMaModelOn: html
]

{ #category : #rendering }
MEDMaContainerComponent >> rendererClass [
	^MEDMagrittifiedHtmlCanvas
]

{ #category : #accessing }
MEDMaContainerComponent >> superComponent [
	^ superComponent
]

{ #category : #accessing }
MEDMaContainerComponent >> superComponent: anObject [
	superComponent := anObject
]
