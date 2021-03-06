Class {
	#name : #MEDUserViewer,
	#superclass : #MEDUserComponentBase,
	#category : #'Mediaclue-View'
}

{ #category : #'as yet unclassified' }
MEDUserViewer >> editMyself [
	self show: (MEDUserEditor model: model) onAnswer: [ self refresh ]
]

{ #category : #rendering }
MEDUserViewer >> renderModelOn: html [
	html pageHeader: [
		html text: 'Benutzer "'.
		html text: model displayName.
		html text: '"'.
	].
	html pageBody: [
		html anchorButton
			callback: [ self editMyself ];
			with: 'Bearbeiten'.
		model isAuthenticateAtLdap ifFalse: [
			html anchorButton
				callback: [ self setLocalPassword ];
				with: 'Passwort setzen'].
				
		html maGrid: #firstName.
		html maGrid: #lastName.
		html maGrid: #email.
		html maGrid: #ldapUid.
		html maGrid: #isAdmin.
		html maGrid: #disabled.
	]

]

{ #category : #initialization }
MEDUserViewer >> setLocalPassword [
	(self request: 'Neues Passwort?') ifNotBlank: [ :pw |
		model password: pw.
		model save.
		self flashMessage: 'Passwort geändert' ]
]
