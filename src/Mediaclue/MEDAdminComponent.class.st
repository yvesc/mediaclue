Class {
	#name : #MEDAdminComponent,
	#superclass : #WEBPagedComponent,
	#traits : 'TMEDComponent',
	#classTraits : 'TMEDComponent classTrait',
	#instVars : [
		'users',
		'userGroups',
		'ldapWizard',
		'configEditor'
	],
	#category : #'Mediaclue-View'
}

{ #category : #'as yet unclassified' }
MEDAdminComponent >> cancelAllJobs [
	self db butler cancelAllFutureJobs
]

{ #category : #'as yet unclassified' }
MEDAdminComponent >> cancelJob: aJob [
	self db butler cancelJob: aJob
]

{ #category : #hooks }
MEDAdminComponent >> children [
	^ Array with: ldapWizard with: configEditor
]

{ #category : #actions }
MEDAdminComponent >> createUser [
	| new |
	new := MEDUser new.
	self show: (MEDUserEditor model: new) onAnswer: [:answer |
		answer ifNotNil: [
			self flashMessage: 'Neu erstellt']
	]
]

{ #category : #actions }
MEDAdminComponent >> createUserGroup [
	| new |
	new := MEDUserGroup new.
	self show: (MEDUserGroupEditor model: new) onAnswer: [:answer |
		answer ifNotNil: [
			self flashMessage: 'Neu erstellt']
	]
]

{ #category : #actions }
MEDAdminComponent >> deleteUser: aUser [
	self delete: aUser then: [
		self flashMessage: 'Gelöscht'.
		self refresh]
]

{ #category : #actions }
MEDAdminComponent >> deleteUserGroup: aGroup [
	self delete: aGroup then: [
		self flashMessage: 'Gelöscht'.
		self refresh]
]

{ #category : #initialization }
MEDAdminComponent >> initialize [
	super initialize.
	
	configEditor := WEBGlobalConfigurationEditor new
]

{ #category : #accessing }
MEDAdminComponent >> pages [
	^ #(config butler stats userGroups users demo ldap)
]

{ #category : #accessing }
MEDAdminComponent >> refresh [
	users := nil.
	userGroups := nil.
]

{ #category : #rendering }
MEDAdminComponent >> renderContentOn: html [
	html pageHeader: 'Admin'.
	html pageBody: [
		self renderPagesMenuOn: html.
		self renderDispatchOn: html.
	].

	
]

{ #category : #rendering }
MEDAdminComponent >> renderPageButlerOn: html [
	| butler |
	butler := self db butler.
	
	html strong: [
		html text: butler jobsCount greaseString.
		html text: ' laufende Jobs:'].
	html break.
	html anchor
		callback: [ self cancelAllJobs ];
		with: [ html iconDelete; space; text: 'Alle Jobs löschen' ].

	html unorderedList
		with: [
			butler currentJobs do: [:eachJob |
				html listItem: [
					html anchor
						callback: [ self cancelJob: eachJob ];
						with: [ html iconDelete ].
					html space.
					html span: eachJob title. ]
	]].
	html strong: 'Abgeschlossene:'; space.
	html unorderedList
		list: butler executedJobSummaries
]

{ #category : #rendering }
MEDAdminComponent >> renderPageConfigOn: html [
	html render: configEditor
]

{ #category : #rendering }
MEDAdminComponent >> renderPageDemoOn: html [
	html form: [ 
		html textArea on: #demoMessage of: self globalConfiguration.
		html submitButton
			callback: [ self globalConfiguration save ];
			with: 'Speichern'
	]
]

{ #category : #rendering }
MEDAdminComponent >> renderPageLdapOn: html [
	| hasLdap |
	hasLdap := (self db identityProvider isKindOf: MEDLdapIdentityProvider).
	
	hasLdap ifFalse: [ html paragraph: 'LDAP nicht aktiviert'. ^ self ].
	
	ldapWizard ifNil: [ 
		html anchorButton
			callback: [ self startLdapWizard ];
			with: 'Start'.
		^self
	].

	html render: ldapWizard	
]

{ #category : #rendering }
MEDAdminComponent >> renderPageStatsOn: html [
	html table: [ 
		html tableRow: [ 
			html tableData: 'Anzahl Medien'.
			html tableData: MEDMediaAsset count asString ].
		html tableRow: [ 
			html tableData: 'Anzahl Kollektionen'.
			html tableData: MEDMediaSet count asString ].
		html tableRow: [ 
			html tableData: 'Anzahl Benutzer'.
			html tableData: MEDUser count asString ]
	]
]

{ #category : #rendering }
MEDAdminComponent >> renderPageUserGroupsOn: html [
	html buttonToolbar: [
		html anchorButton
			callback: [ self createUserGroup ];
			with: 'Erstellen' ].

	html table: [
		self userGroups do: [ :each |
			html tableRow: [
				html tableData: [
					html anchor
						callback: [ self viewUserGroup: each ];
						with: each displayName.
				].
				html tableData: [
					html anchor
						callback: [ self deleteUserGroup: each ];
						with: 'Löschen'.
				].
			]]]
]

{ #category : #rendering }
MEDAdminComponent >> renderPageUsersOn: html [
	html buttonToolbar: [
		html anchorButton
			callback: [ self createUser ];
			with: 'Erstellen' ].
	
	html table: [
		self users do: [ :each |
			html tableRow: [
				html tableData: [
					html anchor
						callback: [ self viewUser: each ];
						with: each displayName].
				html tableData: [ 
					html anchor
						callback: [ self deleteUser: each ];
						with: 'Löschen' ]
			]
		]]
]

{ #category : #actions }
MEDAdminComponent >> startLdapWizard [
	ldapWizard := WEBLdapUserMatchWizard new
		onSaveUser: [ :each | each save ];
		onEditUser: [ :each | self viewUser: each ];
		yourself
]

{ #category : #accessing }
MEDAdminComponent >> userGroups [
	^ userGroups ifNil: [ userGroups := self db userGroups sortedBySortKey ]
]

{ #category : #accessing }
MEDAdminComponent >> users [
	^ users ifNil: [ users := self db users sortedBySortKey ]
]

{ #category : #actions }
MEDAdminComponent >> viewUser: aUser [
	self showWithBack: (MEDUserViewer model: aUser)
]

{ #category : #actions }
MEDAdminComponent >> viewUserGroup: aUserGroup [
	self showWithBack: (MEDUserGroupViewer model: aUserGroup)
]
