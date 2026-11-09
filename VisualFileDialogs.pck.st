'From Cuis7.9 [latest update: #8166] on 7 November 2026 at 12:00:00 pm'!
'Description Morphic File Out and File In dialogs. Original File Out remains available.'!
!provides: 'VisualFileDialogs' 1 0!
SystemOrganization addCategory: #VisualFileDialogs!

!classDefinition: #VisualFileDialogModel category: #VisualFileDialogs!
FileList subclass: #VisualFileDialogModel
	instanceVariableNames: 'rootDirectory'
	classVariableNames: 'LastDirectories'
	poolDictionaries: ''
	category: 'VisualFileDialogs'!

!VisualFileDialogModel methodsFor: 'initialization' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
directory: aDirectory

	(self allowsDirectory: aDirectory) ifFalse: [ ^ self ].
	listIndex := 0.
	^ super directory: aDirectory
! !

!VisualFileDialogModel methodsFor: 'initialization' stamp: 'HAW 7/Nov/2026, 4:26:56 pm (UTC)'!
initialize

	super initialize.
	rootDirectory := VisualFileDialogs homeDirectory.
	showHidden := false.
	showDirsInFileList := true.
	sortMode := #name.
	sortAscending := true
! !

!VisualFileDialogModel methodsFor: 'initialization' stamp: 'HAW 7/Nov/2026, 4:27:16 pm (UTC)'!
topDirectoryWrappers

	topDirectories := {rootDirectory}.
	^ {VisualFileDialogsDirectoryWrapper with: rootDirectory name: rootDirectory name model: self}
! !


!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
allowsDirectory: aDirectory

	aDirectory ifNil: [ ^ false ].
	^ rootDirectory drive = aDirectory drive
		and: [(rootDirectory isInPathTo: aDirectory)
		and: [self hasVisiblePathTo: aDirectory]]
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
enterSelectedDirectory

	listIndex = 0 ifTrue: [ ^ self ].
	(list at: listIndex) isDirectoryEntry ifTrue: [ self navigateTo: (list at: listIndex) ]
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
fileListIndex: anIndex

	listIndex := anIndex.
	self changed: #fileListIndex.
	anIndex = 0 ifTrue: [ ^ self ].
	(list at: anIndex) isDirectoryEntry ifFalse: [
		self triggerEvent: #chooseName with: (list at: anIndex) name ]
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
goHome

	self navigateTo: rootDirectory
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
goUp

	self navigateTo: directory parent
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
isSymbolicLink: anEntry

	"Do not traverse links out of the visible directory tree."
	^ [ (FileIOAccessor default
				primFileAttribute: anEntry pathName asUtf8Bytes
				attributeNumber: 16) = true ] on: Error do: [ :error | true ]
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
navigateTo: aDirectory

	(self allowsDirectory: aDirectory) ifFalse: [ ^ self ].
	self directory: aDirectory.
	self changed: #topDirectoryWrappers.
	self postOpen
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
postOpen

	topDirectories ifNil: [ self topDirectoryWrappers ].
	^ super postOpen
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
setSelectedDirectoryTo: aWrapper

	(self allowsDirectory: aWrapper withoutListWrapper) ifFalse: [ ^ self ].
	^ super setSelectedDirectoryTo: aWrapper
! !


!VisualFileDialogModel methodsFor: 'file list' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
fileList

	^ list collect: [ :entry | entry isDirectoryEntry
			ifTrue: [ entry name, ' /' ]
			ifFalse: [ entry name ] ]
! !

!VisualFileDialogModel methodsFor: 'file list' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
listForSelectingPatterns: selecting rejectingPatterns: rejecting

	^ (super listForSelectingPatterns: selecting rejectingPatterns: rejecting)
		reject: [ :entry | entry isDirectoryEntry and: [ (self allowsDirectory: entry) not ] ]
! !


!VisualFileDialogModel methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
rootDirectory

	^ rootDirectory
! !

!VisualFileDialogModel methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
showHidden

	^ false
! !


!VisualFileDialogModel methodsFor: 'validation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
fileNamed: name

	(self isValidFileName: name) ifFalse: [self error: 'Enter a file name supported by the operating system, without a path.'].
	(self allowsDirectory: directory) ifFalse: [self error: 'Choose a folder inside your home directory.'].
	^ directory // name
! !

!VisualFileDialogModel methodsFor: 'validation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
isValidFileName: name

	^ name notEmpty
		and: [(self hasInvalidFileNameEnding: name) not
		and: [(self hasInvalidFileNameCharacters: name) not
		and: [(self isReservedFileName: name) not]]]
! !


!VisualFileDialogModel methodsFor: 'persistence' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
rememberDirectory

	self class rememberDirectory: directory
! !

!VisualFileDialogModel methodsFor: 'persistence' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
restoreDirectory

	| path candidate |
	self goHome.
	path := self class rememberedDirectoryPath.
	path isEmptyOrNil ifTrue: [ ^ self ].
	[candidate := path asDirectoryEntry.
		((self allowsDirectory: candidate) and: [candidate exists])
			ifTrue: [self navigateTo: candidate]] on: Error do: [:error | self goHome]
! !

!VisualFileDialogModel methodsFor: 'validation - private' stamp: 'VFD 7/Nov/2026 12:00:00'!
hasInvalidFileNameEnding: name

	^ name last = $. or: [name last = Character space]
! !

!VisualFileDialogModel methodsFor: 'validation - private' stamp: 'VFD 7/Nov/2026 12:00:00'!
hasInvalidFileNameCharacters: name

	^ name anySatisfy: [:character |
		character codePoint < 32 or: ['/\:<>"|?*' includes: character]]
! !

!VisualFileDialogModel methodsFor: 'validation - private' stamp: 'VFD 7/Nov/2026 12:00:00'!
isReservedFileName: name

	| base |

	base := (name copyUpTo: $.) asUppercase.
	^ (#('CON' 'PRN' 'AUX' 'NUL') includes: base)
		or: [base size = 4
			and: [(#('COM' 'LPT') includes: (base copyFrom: 1 to: 3))
			and: ['123456789' includes: base last]]]
! !

!VisualFileDialogModel methodsFor: 'navigation - private' stamp: 'VFD 7/Nov/2026 12:00:00'!
hasVisiblePathTo: aDirectory

	| candidate components |

	components := aDirectory pathComponents allButFirst: rootDirectory pathComponents size.
	(components anySatisfy: [:each | each beginsWith: '.']) ifTrue: [ ^ false ].
	candidate := rootDirectory.
	^ components noneSatisfy: [:each |
		candidate := candidate / each.
		self isSymbolicLink: candidate]
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'VisualFileDialogModel class' category: #VisualFileDialogs!
VisualFileDialogModel class
	instanceVariableNames: ''!

!VisualFileDialogModel class methodsFor: 'persistence' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
rememberDirectory: aDirectory

	self rememberedDirectories at: self name put: aDirectory pathName
! !

!VisualFileDialogModel class methodsFor: 'persistence' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
rememberedDirectoryPath

	^ self rememberedDirectories at: self name ifAbsent: [nil]
! !

!VisualFileDialogModel class methodsFor: 'persistence - private' stamp: 'VFD 7/Nov/2026 12:00:00'!
rememberedDirectories

	^ LastDirectories ifNil: [LastDirectories := Dictionary new]
! !


!classDefinition: #VisualFileInModel category: #VisualFileDialogs!
VisualFileDialogModel subclass: #VisualFileInModel
	instanceVariableNames: 'selectedIndices'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogs'!

!VisualFileInModel methodsFor: 'initialization' stamp: 'VFD 8/Nov/2026 12:00:00'!
initialize

	selectedIndices := Set new.
	super initialize
! !

!VisualFileInModel methodsFor: 'navigation' stamp: 'VFD 8/Nov/2026 12:00:00'!
directory: aDirectory

	(self allowsDirectory: aDirectory) ifFalse: [^ self].
	selectedIndices removeAll.
	^ super directory: aDirectory
! !

!VisualFileInModel methodsFor: 'updating' stamp: 'VFD 8/Nov/2026 12:00:00'!
updateFileList
	"FileList refreshes automatically. Preserve selected entries, not their old positions."

	| entries |
	entries := self selectedEntries.
	selectedIndices removeAll.
	super updateFileList.
	self restoreSelectionFrom: entries.
	self selectionChanged
! !

!VisualFileInModel methodsFor: 'selection' stamp: 'VFD 8/Nov/2026 12:00:00'!
fileListIndex: anIndex
	"Keep keyboard navigation and the primary selection compatible with the multiple list."

	super fileListIndex: anIndex.
	anIndex > 0 ifTrue: [self fileListSelectionAt: anIndex put: true]
! !

!VisualFileInModel methodsFor: 'selection' stamp: 'VFD 8/Nov/2026 12:00:00'!
fileListSelectionAt: anIndex

	^ selectedIndices includes: anIndex
! !

!VisualFileInModel methodsFor: 'selection' stamp: 'VFD 8/Nov/2026 12:00:00'!
fileListSelectionAt: anIndex put: aBoolean
	"Called by PluggableListMorphOfMany for clicks and each row crossed while dragging."

	(self includesListIndex: anIndex) ifFalse: [^ self].
	(self fileListSelectionAt: anIndex) = aBoolean ifTrue: [^ self].
	aBoolean
		ifTrue: [selectedIndices add: anIndex]
		ifFalse: [selectedIndices remove: anIndex].
	self selectionChanged
! !

!VisualFileInModel methodsFor: 'selection' stamp: 'VFD 8/Nov/2026 12:00:00'!
selectedSourceFiles

	^ self selectedEntries reject: [:entry | entry isDirectoryEntry]
! !

!VisualFileInModel methodsFor: 'selection - private' stamp: 'VFD 8/Nov/2026 12:00:00'!
selectedEntries

	list ifNil: [^ #()].
	^ selectedIndices asArray sorted collect: [:index | list at: index]
! !

!VisualFileInModel methodsFor: 'selection - private' stamp: 'VFD 8/Nov/2026 12:00:00'!
restoreSelectionFrom: entries

	selectedIndices := (entries
		collect: [:entry | list indexOf: entry]
		thenSelect: [:index | index > 0]) asSet
! !

!VisualFileInModel methodsFor: 'selection - private' stamp: 'VFD 8/Nov/2026 12:00:00'!
includesListIndex: anIndex

	^ list notNil and: [anIndex between: 1 and: list size]
! !

!VisualFileInModel methodsFor: 'selection - private' stamp: 'VFD 8/Nov/2026 12:00:00'!
selectionChanged

	self changed: #allSelections.
	self triggerEvent: #chooseName with: ''
! !

!VisualFileInModel methodsFor: 'file list' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
listForSelectingPatterns: selecting rejectingPatterns: rejecting

	^ (super listForSelectingPatterns: selecting rejectingPatterns: rejecting) select: [ :entry |
		entry isDirectoryEntry or: [ self supportsFile: entry ] ]
! !


!VisualFileInModel methodsFor: 'testing' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
supportsFile: entry

	^ (#('st' 'cs' 'cs.st') includes: entry extension asLowercase)
		and: [ (entry name asLowercase endsWith: '.pck.st') not ]
! !


!VisualFileInModel methodsFor: 'importing' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
importFileNamed: name

	| file |
	file := self fileNamed: name.
	(self supportsFile: file) ifFalse: [self error: 'Choose a .st or .cs file. Use install package for .pck.st packages.'].
	file exists ifFalse: [self error: 'The selected file does not exist.'].
	(self isSymbolicLink: file) ifTrue: [self error: 'Symbolic links cannot be imported.'].
	ChangeSet fileIn: file.
	self rememberDirectory
! !

!VisualFileInModel methodsFor: 'importing' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
importSelectedFile

	| files |
	files := self selectedSourceFiles.
	files isEmpty ifTrue: [self error: 'Select a source file from the list.'].
	files do: [:file | self importFileNamed: file name]
! !


!VisualFileInModel methodsFor: 'selection' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
selectedSourceFile

	(listIndex isNil or: [(self includesListIndex: listIndex) not]) ifTrue: [^ nil].
	(list at: listIndex) isDirectoryEntry ifTrue: [ ^ nil ].
	^ list at: listIndex
! !


!classDefinition: #VisualFileOutModel category: #VisualFileDialogs!
VisualFileDialogModel subclass: #VisualFileOutModel
	instanceVariableNames: 'suggestedName writer'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogs'!

!VisualFileOutModel methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
suggestedName

	^ suggestedName
! !

!VisualFileOutModel methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
suggestedName: aName writer: aBlock

	suggestedName := aName.
	writer := aBlock
! !

!VisualFileOutModel methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
writeOn: stream

	writer value: stream
! !


!VisualFileOutModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
createDirectoryNamed: proposedName

	| name destination |
	name := proposedName withBlanksTrimmed.
	(self isValidFileName: name) ifFalse: [self error: 'Enter a folder name supported by the operating system, without a path.'].
	(name beginsWith: '.') ifTrue: [self error: 'Hidden folders cannot be created in this explorer.'].
	(self allowsDirectory: directory) ifFalse: [self error: 'Choose a folder inside your home directory.'].
	directory invalidateChildren.
	(directory children anySatisfy: [:entry | entry name = name]) ifTrue: [self error: 'A file or folder with that name already exists.'].
	destination := directory / name.
	destination assureExistence.
	destination exists ifFalse: [self error: 'Could not create the folder. Check directory permissions.'].
	self navigateTo: destination.
	^ destination
! !


!VisualFileOutModel methodsFor: 'exporting' stamp: 'VFD 7/Nov/2026, 3:00:00 pm (UTC)'!
renameFile: source to: destination

	source fileAccessor rename: source pathName to: destination pathName.
	source invalidate.
	destination invalidate.
	directory invalidateChildren
! !

!VisualFileOutModel methodsFor: 'exporting' stamp: 'VFD 7/Nov/2026, 3:00:00 pm (UTC)'!
unusedFileWithExtension: extension

	| candidate |
	[candidate := directory // ('VFD-', Time millisecondClockValue asString, '-', 1000000 atRandom asString, extension).
		candidate exists or: [(directory / candidate name) exists]] whileTrue.
	^ candidate
! !

!VisualFileOutModel methodsFor: 'exporting' stamp: 'VFD 7/Nov/2026, 3:00:00 pm (UTC)'!
writeFileNamed: name

	| destination temporary |
	destination := self validatedDestinationNamed: name.
	temporary := self unusedFileWithExtension: '.tmp'.
	[self writeTemporaryFile: temporary.
		self commitTemporaryFile: temporary to: destination.
		self rememberDirectory]
		ensure: [self deleteExportArtifact: temporary].
	^ destination
! !

!VisualFileOutModel methodsFor: 'exporting - private' stamp: 'VFD 7/Nov/2026 12:00:00'!
validatedDestinationNamed: name

	| destination |
	destination := self fileNamed: name.
	(directory / name) exists ifTrue: [self error: 'The destination is a folder. Choose a file name.'].
	(destination exists and: [self isSymbolicLink: destination]) ifTrue: [self error: 'Symbolic links cannot be overwritten.'].
	^ destination
! !

!VisualFileOutModel methodsFor: 'exporting - private' stamp: 'VFD 7/Nov/2026 12:00:00'!
writeTemporaryFile: temporary

	temporary writeStreamDo: [:stream |
		stream ifNil: [self error: 'Could not create the temporary export file.'].
		self writeOn: stream]
! !

!VisualFileOutModel methodsFor: 'exporting - private' stamp: 'VFD 7/Nov/2026 12:00:00'!
commitTemporaryFile: temporary to: destination

	| backup |
	destination exists ifTrue: [
		backup := self unusedFileWithExtension: '.bak'.
		self renameFile: destination to: backup].
	[self renameFile: temporary to: destination]
		on: Error do: [:commitError |
		backup ifNotNil: [self restoreBackup: backup to: destination].
		commitError pass].
	backup ifNotNil: [self deleteExportArtifact: backup]
! !

!VisualFileOutModel methodsFor: 'exporting - private' stamp: 'VFD 7/Nov/2026 12:00:00'!
restoreBackup: backup to: destination

	[self renameFile: backup to: destination]
		on: Error do: [:restoreError |
		self error: 'Export failed. The original file is preserved at ', backup pathName]
! !

!VisualFileOutModel methodsFor: 'exporting - private' stamp: 'VFD 7/Nov/2026 12:00:00'!
deleteExportArtifact: file

	[file invalidate. file exists ifTrue: [file delete]]
		on: Error do: [:cleanupError | nil]
! !


!classDefinition: #VisualFileDialogWindow category: #VisualFileDialogs!
FileListWindow subclass: #VisualFileDialogWindow
	instanceVariableNames: 'pathLabel'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogs'!

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildExplorer

	| row files tree |
	row := LinearLayoutMorph newRow.
	files := self morphicFileListPane.
	files menuNshortcutsKey: nil; doubleClickSelector: #enterSelectedDirectory.
	files allowsMultipleSelection ifFalse: [
		files setBalloonText: 'Double-click to open a folder. Click a file to use its name.'].
	tree := self morphicDirectoryTreePane.
	tree menuNshortcutsKey: nil.
	row addMorph: (self paneTitled: 'Folders' containing: tree) proportionalWidth: 0.32;
		addAdjusterAndMorph: (self paneTitled: 'Files' containing: files) proportionalWidth: 0.68.
	^ row
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildMorphicWindow

	| body |
	body := LinearLayoutMorph newColumn.
	body separation: 10; color: self textBackgroundColor.
	body addMorph: self buildHeader fixedHeight: 56;
		addMorph: self buildNavigation fixedHeight: 36;
		addMorph: self buildExplorer proportionalHeight: 1;
		addMorph: self buildSelectionPane fixedHeight: 76;
		addMorph: self buildActions fixedHeight: 38.
	self layoutMorph addMorphUseAll: body.
	model when: #chooseName send: #chooseName: to: self.
	self morphExtent: 820@590.
	model postOpen
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildNavigation

	| row home up pathPane |
	row := LinearLayoutMorph newRow.
	row separation: 6.
	home := self buttonLabel: 'Home' target: model action: #goHome.
	home setBalloonText: 'Go to your home directory'.
	up := self buttonLabel: 'Up' target: model action: #goUp.
	up setBalloonText: 'Go to the parent folder'.
	pathLabel := LabelMorph contents: self displayDirectory.
	pathLabel setBalloonText: model directory pathName.
	pathPane := LinearLayoutMorph newRow.
	pathPane separation: 8; color: self textBackgroundColor;
		borderWidth: 1; borderColor: self widgetsColor.
	pathPane addMorphUseAll: pathLabel.
	row addMorph: home fixedWidth: (self buttonWidthFor: 'Home');
		addMorph: up fixedWidth: (self buttonWidthFor: 'Up');
		addMorph: pathPane proportionalWidth: 1.
	^ row
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildSelectionPane

	self subclassResponsibility
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buttonLabel: aString target: target action: selector

	^ (PluggableButtonMorph model: target action: selector)
	label: aString;
		color: self buttonColor;
		yourself
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buttonWidthFor: aString

	^ ((Preferences at: #standardButtonFont) widthOfString: aString) + 32
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFD 7/Nov/2026, 3:00:00 pm (UTC)'!
initialExtent

	| lineHeight |
	lineHeight := (Preferences at: #standardListFont) lineSpacing.
	^ ((lineHeight * 40) max: 820) @ ((lineHeight * 24) max: 590)
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
paneTitled: aTitle containing: aMorph

	| pane heading caption |
	pane := LinearLayoutMorph newColumn.
	pane color: self textBackgroundColor; gap: 0.
	heading := LinearLayoutMorph newRow.
	heading separation: 8; color: self windowColor.
	caption := LabelMorph contents: aTitle.
	caption emphasis: AbstractFont boldCode.
	heading addMorphUseAll: caption.
	pane addMorph: heading fixedHeight: 32;
		addMorphUseAll: aMorph.
	^ pane
! !


!VisualFileDialogWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
chooseName: aString

	self subclassResponsibility
! !

!VisualFileDialogWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
displayDirectory

	| parts |
	parts := model directory pathComponents allButFirst: model rootDirectory pathComponents size.
	^ (String streamContents: [ :stream |
			stream nextPutAll: 'Home'.
			parts do: [ :part | stream nextPutAll: ' / '; nextPutAll: part ] ]) squeezedTo: 72
! !

!VisualFileDialogWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
relabel

	pathLabel ifNotNil: [ pathLabel contents: self displayDirectory.
		pathLabel setBalloonText: model directory pathName ]
! !


!VisualFileDialogWindow methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
enterSelectedDirectory

	"PluggableListMorph sends double-click actions to its containing window."
	^ model enterSelectedDirectory
! !


!classDefinition: #VisualFileInWindow category: #VisualFileDialogs!
VisualFileDialogWindow subclass: #VisualFileInWindow
	instanceVariableNames: 'selectionLabel'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogs'!

!VisualFileInWindow methodsFor: 'GUI building' stamp: 'VFD 8/Nov/2026 12:00:00'!
morphicFileListPane

	^ (PluggableListMorphOfMany
		withModel: model
		listGetter: #fileList
		primarySelectionGetter: #fileListIndex
		primarySelectionSetter: #fileListIndex:
		listSelectionGetter: #fileListSelectionAt:
		listSelectionSetter: #fileListSelectionAt:put:)
		menuNshortcutsKey: #fileListMenuSpec;
		setBalloonText: 'Click to mark or unmark files. Drag to select several. Double-click a folder to open it.';
		yourself
! !

!VisualFileInWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildActions

	| row hint cancel open |
	row := LinearLayoutMorph newRow.
	row gap: 8.
	hint := LabelMorph contents: 'Smalltalk source (.st, .cs)'.
	cancel := self buttonLabel: 'Cancel' target: self action: #delete.
	open := self buttonLabel: 'File In' target: self action: #importFile.
	open borderWidth: 2; setBalloonText: 'Load the selected source files in list order into this image'.
	row addMorph: hint proportionalWidth: 1;
		addMorph: cancel fixedWidth: (self buttonWidthFor: 'Cancel');
		addMorph: open fixedWidth: (self buttonWidthFor: 'File In').
	^ row
! !

!VisualFileInWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildHeader

	| header title subtitle |
	header := LinearLayoutMorph newColumn.
	header separation: 4; axisEdgeWeight: #columnTop.
	title := LabelMorph contents: 'Import Code'.
	title emphasis: AbstractFont boldCode.
	subtitle := LabelMorph contents: 'Choose one or more Smalltalk source files to load into this image.'.
	header addMorphKeepMorphHeight: title; addMorphKeepMorphHeight: subtitle.
	^ header
! !

!VisualFileInWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildSelectionPane

	| pane heading |
	pane := LinearLayoutMorph newColumn.
	pane gap: 6; padding: 8; borderWidth: 1; borderColor: self widgetsColor;
		color: self textBackgroundColor.
	heading := LabelMorph contents: 'Selected files'.
	heading emphasis: AbstractFont boldCode.
	selectionLabel := LabelMorph contents: self selectionText.
	pane addMorphKeepMorphHeight: heading; addMorphUseAll: selectionLabel.
	^ pane
! !


!VisualFileInWindow methodsFor: 'importing' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
importFile

	[model importSelectedFile]
		on: Error do: [ :error | ^ self inform: error description ].
	self delete
! !


!VisualFileInWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
chooseName: aString

	selectionLabel ifNotNil: [selectionLabel contents: self selectionText]
! !

!VisualFileInWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
relabel

	super relabel.
	selectionLabel ifNotNil: [selectionLabel contents: self selectionText]
! !

!VisualFileInWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
selectionText

	| files |
	files := model selectedSourceFiles.
	files isEmpty ifTrue: [^ 'Select source files from the list.'].
	files size = 1 ifTrue: [^ files first name].
	^ files size asString, ' files selected'
! !


!classDefinition: #VisualFileOutWindow category: #VisualFileDialogs!
VisualFileDialogWindow subclass: #VisualFileOutWindow
	instanceVariableNames: 'nameField'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogs'!

!VisualFileOutWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
chooseName: aString

	nameField contents: aString
! !


!VisualFileOutWindow methodsFor: 'saving' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
saveFile

	| name file |
	name := nameField contents withBlanksTrimmed.
	[file := model fileNamed: name]
		on: Error do: [:error | ^ self inform: error description].
	file exists ifTrue: [
		(self confirmOverwrite: file) ifFalse: [ ^ self ]].
	[model writeFileNamed: name]
		on: Error do: [:error | ^ self inform: error description].
	self delete
! !


!VisualFileOutWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildActions

	| row hint save cancel |
	row := LinearLayoutMorph newRow.
	row gap: 8.
	hint := LabelMorph contents: 'Smalltalk code (.st)'.
	cancel := self buttonLabel: 'Cancel' target: self action: #delete.
	save := self buttonLabel: 'Save' target: self action: #saveFile.
	save borderWidth: 2.
	save setBalloonText: 'Export the code to the selected folder'.
	row addMorph: hint proportionalWidth: 1;
		addMorph: cancel fixedWidth: (self buttonWidthFor: 'Cancel');
		addMorph: save fixedWidth: (self buttonWidthFor: 'Save').
	^ row
! !

!VisualFileOutWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildFileNamePane

	| pane label row |
	pane := LinearLayoutMorph newColumn.
	pane gap: 6; padding: 8;
		borderWidth: 1; borderColor: self widgetsColor;
		color: self textBackgroundColor.
	label := LabelMorph contents: 'File name'.
	label emphasis: AbstractFont boldCode.
	nameField := EntryFieldMorph contents: model suggestedName.
	nameField borderWidth: 1; borderColor: self widgetsColor;
		backgroundColor: self textBackgroundColor;
		setBalloonText: 'Enter the file name, including its .st extension'.
	row := LinearLayoutMorph newRow.
	row addMorphUseAll: nameField.
	pane addMorphKeepMorphHeight: label;
		addMorph: row proportionalHeight: 1.
	^ pane
! !

!VisualFileOutWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildHeader

	| header title subtitle |
	header := LinearLayoutMorph newColumn.
	header separation: 4; axisEdgeWeight: #columnTop.
	title := LabelMorph contents: 'Export Code'.
	title emphasis: AbstractFont boldCode.
	subtitle := LabelMorph contents: 'Choose a folder and save your Smalltalk file.'.
	header addMorphKeepMorphHeight: title;
		addMorphKeepMorphHeight: subtitle.
	^ header
! !

!VisualFileOutWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildNavigation

	| row button |
	row := super buildNavigation.
	button := self buttonLabel: 'New Folder' target: self action: #createDirectory.
	button setBalloonText: 'Create a folder in the current location and open it'.
	row addMorph: button fixedWidth: (self buttonWidthFor: 'New Folder').
	^ row
! !

!VisualFileOutWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
buildSelectionPane

	^ self buildFileNamePane
! !


!VisualFileOutWindow methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
createDirectory

	| name |
	name := self requestFolderName.
	name ifNil: [ ^ self ].
	[model createDirectoryNamed: name]
		on: Error do: [:error | self inform: error description]
! !


!VisualFileOutWindow methodsFor: 'dialogs' stamp: 'VFD 7/Nov/2026, 3:00:00 pm (UTC)'!
confirmOverwrite: file

	^ PopUpMenu confirm: 'The file already exists. Overwrite it?'
! !

!VisualFileOutWindow methodsFor: 'dialogs' stamp: 'VFD 7/Nov/2026, 3:00:00 pm (UTC)'!
requestFolderName

	^ StringRequestMorph request: 'New folder name' initialAnswer: '' orCancel: [nil]
! !


!classDefinition: #VisualFileDialogsDirectoryWrapper category: #VisualFileDialogs!
FileDirectoryWrapper subclass: #VisualFileDialogsDirectoryWrapper
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogs'!

!VisualFileDialogsDirectoryWrapper methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
contents

	| children |
	children := item directories select: [ :entry | model allowsDirectory: entry ].
	^ (children asArray sort: [ :a :b | a name caseInsensitiveLessOrEqual: b name ])
		collect: [ :entry | self class with: entry name: entry name model: model ]
! !


!classDefinition: #VisualFileDialogs category: #VisualFileDialogs!
Object subclass: #VisualFileDialogs
	instanceVariableNames: ''
	classVariableNames: 'Enabled'
	poolDictionaries: ''
	category: 'VisualFileDialogs'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'VisualFileDialogs class' category: #VisualFileDialogs!
VisualFileDialogs class
	instanceVariableNames: ''!

!VisualFileDialogs class methodsFor: 'activation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
disable

	self unload
! !

!VisualFileDialogs class methodsFor: 'activation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
enable

	self initialize
! !

!VisualFileDialogs class methodsFor: 'activation' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
isEnabled

	^ Enabled = true
! !


!VisualFileDialogs class methodsFor: 'initialization' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
initialize

	Enabled := true.
	self browserMenuKeys do: [ :key |
		BrowserWindow at: key registerMenuAndShortcutsSpecProvider: (MessageSend receiver: self selector: key) ]
! !

!VisualFileDialogs class methodsFor: 'initialization' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
unload

	Enabled := false.
	self browserMenuKeys do: [ :key |
		BrowserWindow at: key unregisterMenuAndShortcutsSpecProvider: (MessageSend receiver: self selector: key) ]
! !


!VisualFileDialogs class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
classListMenuSpec

	^ self fileMenuSpecAt: 115 exportSelector: #visualFileOutClass
! !

!VisualFileDialogs class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
fileMenuSpecAt: position exportSelector: selector

	^ { {position. 'File Out with Explorer (O)'. $O. #model. selector. #fileOutIcon} }
! !

!VisualFileDialogs class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
messageCatListMenuSpec

	^ self fileMenuSpecAt: 15 exportSelector: #visualFileOutMessageCategory
! !

!VisualFileDialogs class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
messageListMenuSpec

	^ self fileMenuSpecAt: 55 exportSelector: #visualFileOutMessage
! !

!VisualFileDialogs class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
systemCatListMenuSpec

	^ self fileMenuSpecAt: 75 exportSelector: #visualFileOutSystemCategory
! !

!VisualFileDialogs class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
systemCatSingletonMenuSpec

	^ self fileMenuSpecAt: 65 exportSelector: #visualFileOutSystemCategory
! !


!VisualFileDialogs class methodsFor: 'opening' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
openFileIn

	| model |
	model := VisualFileInModel new.
	model restoreDirectory.
	^ VisualFileInWindow open: model label: 'File In - Open File'
! !

!VisualFileDialogs class methodsFor: 'opening' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
suggestedFileName: aName writeStreamDo: aBlock

	| model |
	model := VisualFileOutModel new.
	model restoreDirectory; suggestedName: aName writer: aBlock.
	^ VisualFileOutWindow open: model label: 'File Out - Save File'
! !


!VisualFileDialogs class methodsFor: 'directories' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
environmentAt: key

	| raw |
	raw := self primitiveEnvironmentAt: key.
	raw ifNil: [ ^ nil ].
	^ UnicodeString fromUtf8Bytes: raw asByteArray
! !

!VisualFileDialogs class methodsFor: 'directories' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
homeDirectory

	| path home |
	path := self homePathFor: Smalltalk platformName environment: [:key | self environmentAt: key].
	path isEmptyOrNil ifTrue: [self error: 'The operating system did not provide a home directory. Check HOME or USERPROFILE.'].
	path isAbsolutePathName ifFalse: [self error: 'The home directory must be an absolute path.'].
	home := path asDirectoryEntry.
	(home exists and: [home isRoot not]) ifFalse: [self error: 'The home directory is missing or is a filesystem root.'].
	^ home
! !

!VisualFileDialogs class methodsFor: 'directories' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
homePathFor: platform environment: lookup

	| path drive relative |
	(platform asLowercase beginsWith: 'win') ifFalse: [ ^ lookup value: 'HOME' ].
	path := lookup value: 'USERPROFILE'.
	path isEmptyOrNil ifFalse: [ ^ path ].
	drive := lookup value: 'HOMEDRIVE'.
	relative := lookup value: 'HOMEPATH'.
	(drive isEmptyOrNil or: [relative isEmptyOrNil]) ifTrue: [ ^ nil ].
	^ drive, relative
! !

!VisualFileDialogs class methodsFor: 'directories' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
primitiveEnvironmentAt: key

	"Built-in VM primitive, shared by the Linux, macOS and Windows VMs."
	<primitive: 'primitiveGetenv' module: ''>
	^ nil
! !


!VisualFileDialogs class methodsFor: 'menu-world' stamp: 'VFO 7/Nov/2026, 3:00:00 pm (UTC)'!
worldMenuOptions

	self isEnabled ifFalse: [ ^ #() ].
	^ { {
			#itemGroup -> 10.
			#itemOrder -> 15.
			#label -> 'File In with Explorer'.
			#object -> self.
			#selector -> #openFileIn.
			#icon -> #scriptIcon.
			#balloonText -> 'Import a Smalltalk source file'.
		} asDictionary }
! !

!VisualFileDialogs class methodsFor: 'menu & kbd shortcuts' stamp: 'VFD 7/Nov/2026 12:00:00'!
browserMenuKeys

	^ #(systemCatListMenuSpec systemCatSingletonMenuSpec classListMenuSpec messageCatListMenuSpec messageListMenuSpec)
! !

!Browser methodsFor: '*VisualFileDialogs' stamp: 'VFO 7/Nov/2026 12:00:00'!
visualFileOutClass

	| aClass |
	aClass := self selectedClass.
	aClass ifNil: [ ^ self ].
	^ VisualFileDialogs suggestedFileName: aClass name, '.st' writeStreamDo: [ :stream |
		aClass sharedPools notEmpty ifTrue: [aClass shouldFileOutPools ifTrue: [aClass fileOutSharedPoolsOn: stream]].
		aClass fileOutOn: stream moveSource: false toFile: 0 ]
! !

!Browser methodsFor: '*VisualFileDialogs' stamp: 'VFO 7/Nov/2026 12:00:00'!
visualFileOutSystemCategory

	| category organizer |
	category := self selectedSystemCategory.
	category ifNil: [ ^ self ].
	organizer := systemOrganizer.
	^ VisualFileDialogs suggestedFileName: category asFileName, '.st' writeStreamDo: [ :stream |
		(organizer withSubCategoriesOf: category) do: [ :each |
			organizer fileOutCategory: each on: stream initializing: true ]]
! !

!Browser methodsFor: '*VisualFileDialogs' stamp: 'VFO 7/Nov/2026 12:00:00'!
visualFileOutMessageCategory

	| aClass category |
	aClass := self selectedClassOrMetaClass.
	category := self selectedMessageCategoryName.
	(aClass isNil or: [category isNil]) ifTrue: [ ^ self ].
	^ VisualFileDialogs suggestedFileName: aClass name, '-', category, '.st' writeStreamDo: [ :stream |
		stream writeSystemTimeStamp.
		aClass fileOutCategory: category on: stream moveSource: false toFile: 0 ]
! !

!Browser methodsFor: '*VisualFileDialogs' stamp: 'VFO 7/Nov/2026 12:00:00'!
visualFileOutMessage

	| aClass selector |
	aClass := self selectedClassOrMetaClass.
	selector := self selectedMessageName.
	(aClass isNil or: [selector isNil]) ifTrue: [ ^ self ].
	^ VisualFileDialogs suggestedFileName: aClass name, '-', selector asFileName, '.st' writeStreamDo: [ :stream |
		stream writeSystemTimeStamp.
		aClass printMethodChunk: selector withPreamble: true on: stream moveSource: false toFile: 0 ]
! !

VisualFileDialogs initialize!