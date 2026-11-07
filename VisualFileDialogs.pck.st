'From Cuis7.9 [latest update: #8166] on 7 November 2026 at 12:00:00 pm'!
'Description Morphic File Out and File In dialogs. Original File Out remains available.'!
!provides: 'VisualFileDialogs' 1 6!
SystemOrganization addCategory: #VisualFileDialogs!

!classDefinition: #VisualFileOut category: #VisualFileDialogs!
Object subclass: #VisualFileOut
 instanceVariableNames: ''
 classVariableNames: 'Enabled'
 poolDictionaries: ''
 category: 'VisualFileDialogs'!
!classDefinition: 'VisualFileOut class' category: #VisualFileDialogs!
VisualFileOut class instanceVariableNames: ''!

(Smalltalk at: #VisualFileOutModel ifAbsent: [nil]) ifNotNil: [ :oldClass |
 (oldClass instVarNames includes: 'rootDirectory') ifTrue: [oldClass removeInstVarName: 'rootDirectory'] ]!
(Smalltalk at: #VisualFileOutWindow ifAbsent: [nil]) ifNotNil: [ :oldClass |
 (oldClass instVarNames includes: 'pathLabel') ifTrue: [oldClass removeInstVarName: 'pathLabel'] ]!

!classDefinition: #VisualFileDialogModel category: #VisualFileDialogs!
FileList subclass: #VisualFileDialogModel
 instanceVariableNames: 'rootDirectory'
 classVariableNames: 'LastDirectories'
 poolDictionaries: ''
 category: 'VisualFileDialogs'!
!classDefinition: 'VisualFileDialogModel class' category: #VisualFileDialogs!
VisualFileDialogModel class instanceVariableNames: ''!

!classDefinition: #VisualFileDialogWindow category: #VisualFileDialogs!
FileListWindow subclass: #VisualFileDialogWindow
 instanceVariableNames: 'pathLabel'
 classVariableNames: ''
 poolDictionaries: ''
 category: 'VisualFileDialogs'!
!classDefinition: 'VisualFileDialogWindow class' category: #VisualFileDialogs!
VisualFileDialogWindow class instanceVariableNames: ''!

!classDefinition: #VisualFileOutModel category: #VisualFileDialogs!
VisualFileDialogModel subclass: #VisualFileOutModel
 instanceVariableNames: 'suggestedName writer'
 classVariableNames: ''
 poolDictionaries: ''
 category: 'VisualFileDialogs'!
!classDefinition: 'VisualFileOutModel class' category: #VisualFileDialogs!
VisualFileOutModel class instanceVariableNames: ''!

!classDefinition: #VisualFileOutWindow category: #VisualFileDialogs!
VisualFileDialogWindow subclass: #VisualFileOutWindow
 instanceVariableNames: 'nameField'
 classVariableNames: ''
 poolDictionaries: ''
 category: 'VisualFileDialogs'!
!classDefinition: 'VisualFileOutWindow class' category: #VisualFileDialogs!
VisualFileOutWindow class instanceVariableNames: ''!

!VisualFileOut class methodsFor: 'activation' stamp: 'VFO 7/Nov/2026 12:00:00'!
enable
 self initialize
! !

!VisualFileOut class methodsFor: 'activation' stamp: 'VFO 7/Nov/2026 12:00:00'!
disable
 self unload
! !

!VisualFileOut class methodsFor: 'activation' stamp: 'VFO 7/Nov/2026 12:00:00'!
isEnabled
 ^ Enabled = true
! !

!VisualFileOut class methodsFor: 'initialization' stamp: 'VFO 7/Nov/2026 12:00:00'!
initialize
 Enabled := true.
 #(systemCatListMenuSpec systemCatSingletonMenuSpec classListMenuSpec messageCatListMenuSpec messageListMenuSpec) do: [ :key |
 BrowserWindow at: key registerMenuAndShortcutsSpecProvider: (MessageSend receiver: self selector: key) ]
! !

!VisualFileOut class methodsFor: 'initialization' stamp: 'VFO 7/Nov/2026 12:00:00'!
unload
 Enabled := false.
 #(systemCatListMenuSpec systemCatSingletonMenuSpec classListMenuSpec messageCatListMenuSpec messageListMenuSpec) do: [ :key |
 BrowserWindow at: key unregisterMenuAndShortcutsSpecProvider: (MessageSend receiver: self selector: key) ]
! !

!VisualFileOut class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026 12:00:00'!
systemCatListMenuSpec
 ^ self fileMenuSpecAt: 75 exportSelector: #visualFileOutSystemCategory
! !

!VisualFileOut class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026 12:00:00'!
classListMenuSpec
 ^ self fileMenuSpecAt: 115 exportSelector: #visualFileOutClass
! !

!VisualFileOut class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026 12:00:00'!
messageCatListMenuSpec
 ^ self fileMenuSpecAt: 15 exportSelector: #visualFileOutMessageCategory
! !

!VisualFileOut class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026 12:00:00'!
messageListMenuSpec
 ^ self fileMenuSpecAt: 55 exportSelector: #visualFileOutMessage
! !

!VisualFileOut class methodsFor: 'opening' stamp: 'VFO 7/Nov/2026 12:00:00'!
suggestedFileName: aName writeStreamDo: aBlock
 | model |
 model := VisualFileOutModel new.
 model restoreDirectory; suggestedName: aName writer: aBlock.
 ^ VisualFileOutWindow open: model label: 'File Out - Save File'
! !

!VisualFileDialogModel methodsFor: 'initialization' stamp: 'VFO 7/Nov/2026 12:00:00'!
initialize
 super initialize.
 rootDirectory := VisualFileOut homeDirectory.
 showHidden := false.
 showDirsInFileList := true.
 sortMode := #name.
 sortAscending := true
! !

!VisualFileOutModel methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026 12:00:00'!
suggestedName: aName writer: aBlock
 suggestedName := aName.
 writer := aBlock
! !

!VisualFileOutModel methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026 12:00:00'!
suggestedName
 ^ suggestedName
! !

!VisualFileOutModel methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026 12:00:00'!
writeOn: stream
 writer value: stream
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
fileListIndex: anIndex
 listIndex := anIndex.
 self changed: #fileListIndex.
 anIndex = 0 ifTrue: [ ^ self ].
 (list at: anIndex) isDirectoryEntry ifFalse: [
 self triggerEvent: #chooseName with: (list at: anIndex) name ]
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
enterSelectedDirectory
 listIndex = 0 ifTrue: [ ^ self ].
 (list at: listIndex) isDirectoryEntry ifTrue: [ self navigateTo: (list at: listIndex) ]
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
navigateTo: aDirectory
 (self allowsDirectory: aDirectory) ifFalse: [ ^ self ].
 self directory: aDirectory.
 self changed: #topDirectoryWrappers.
 self postOpen
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
goUp
 self navigateTo: directory parent
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
goHome
 self navigateTo: rootDirectory
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
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

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
buttonLabel: aString target: target action: selector
 ^ (PluggableButtonMorph model: target action: selector)
 label: aString;
 color: self buttonColor;
 yourself
! !

!VisualFileDialogWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026 12:00:00'!
relabel
 pathLabel ifNotNil: [ pathLabel contents: self displayDirectory.
 pathLabel setBalloonText: model directory pathName ]
! !

!VisualFileOutWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026 12:00:00'!
chooseName: aString
 nameField contents: aString
! !

!VisualFileOutWindow methodsFor: 'saving' stamp: 'VFO 7/Nov/2026 12:00:00'!
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

!Browser methodsFor: '*VisualFileDialogs' stamp: 'VFO 7/Nov/2026 12:00:00'!
visualFileOutClass
 | aClass |
 aClass := self selectedClass.
 aClass ifNil: [ ^ self ].
 ^ VisualFileOut suggestedFileName: aClass name, '.st' writeStreamDo: [ :stream |
 aClass sharedPools notEmpty ifTrue: [aClass shouldFileOutPools ifTrue: [aClass fileOutSharedPoolsOn: stream]].
 aClass fileOutOn: stream moveSource: false toFile: 0 ]
! !

!Browser methodsFor: '*VisualFileDialogs' stamp: 'VFO 7/Nov/2026 12:00:00'!
visualFileOutSystemCategory
 | category organizer |
 category := self selectedSystemCategory.
 category ifNil: [ ^ self ].
 organizer := systemOrganizer.
 ^ VisualFileOut suggestedFileName: category asFileName, '.st' writeStreamDo: [ :stream |
 (organizer withSubCategoriesOf: category) do: [ :each |
 organizer fileOutCategory: each on: stream initializing: true ]] 
! !

!Browser methodsFor: '*VisualFileDialogs' stamp: 'VFO 7/Nov/2026 12:00:00'!
visualFileOutMessageCategory
 | aClass category |
 aClass := self selectedClassOrMetaClass.
 category := self selectedMessageCategoryName.
 (aClass isNil or: [category isNil]) ifTrue: [ ^ self ].
 ^ VisualFileOut suggestedFileName: aClass name, '-', category, '.st' writeStreamDo: [ :stream |
 stream writeSystemTimeStamp.
 aClass fileOutCategory: category on: stream moveSource: false toFile: 0 ]
! !

!Browser methodsFor: '*VisualFileDialogs' stamp: 'VFO 7/Nov/2026 12:00:00'!
visualFileOutMessage
 | aClass selector |
 aClass := self selectedClassOrMetaClass.
 selector := self selectedMessageName.
 (aClass isNil or: [selector isNil]) ifTrue: [ ^ self ].
 ^ VisualFileOut suggestedFileName: aClass name, '-', selector asFileName, '.st' writeStreamDo: [ :stream |
 stream writeSystemTimeStamp.
 aClass printMethodChunk: selector withPreamble: true on: stream moveSource: false toFile: 0 ]
! !

!DirectoryEntry class methodsFor: 'user default directories' stamp: 'VFO 7/Nov/2026 12:00:00'!
fileOutsDirQuery: suggestedFileName writeStreamDo: writeBlock
 self userDirectory: 'FileOuts' queryFileName: suggestedFileName writeStreamDo: writeBlock
! !

!VisualFileDialogModel methodsFor: 'file list' stamp: 'VFO 7/Nov/2026 12:00:00'!
fileList
 ^ list collect: [ :entry | entry isDirectoryEntry
 ifTrue: [ entry name, ' /' ]
 ifFalse: [ entry name ] ]
! !

!classDefinition: #VisualFileOutDirectoryWrapper category: #VisualFileDialogs!
FileDirectoryWrapper subclass: #VisualFileOutDirectoryWrapper
 instanceVariableNames: ''
 classVariableNames: ''
 poolDictionaries: ''
 category: 'VisualFileDialogs'!
!classDefinition: 'VisualFileOutDirectoryWrapper class' category: #VisualFileDialogs!
VisualFileOutDirectoryWrapper class instanceVariableNames: ''!

!VisualFileOut class methodsFor: 'directories' stamp: 'VFO 7/Nov/2026 12:00:00'!
homeDirectory
 | path home |
 path := self homePathFor: Smalltalk platformName environment: [:key | self environmentAt: key].
 path isEmptyOrNil ifTrue: [self error: 'The operating system did not provide a home directory. Check HOME or USERPROFILE.'].
 path isAbsolutePathName ifFalse: [self error: 'The home directory must be an absolute path.'].
 home := path asDirectoryEntry.
 (home exists and: [home isRoot not]) ifFalse: [self error: 'The home directory is missing or is a filesystem root.'].
 ^ home
! !

!VisualFileDialogModel methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026 12:00:00'!
rootDirectory
 ^ rootDirectory
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
allowsDirectory: aDirectory
 | candidate components |
 aDirectory ifNil: [ ^ false ].
 (rootDirectory drive = aDirectory drive) ifFalse: [ ^ false ].
 (rootDirectory isInPathTo: aDirectory) ifFalse: [ ^ false ].
 components := aDirectory pathComponents allButFirst: rootDirectory pathComponents size.
 (components anySatisfy: [ :each | each beginsWith: '.' ]) ifTrue: [ ^ false ].
 candidate := rootDirectory.
 components do: [ :each |
 candidate := candidate / each.
 (self isSymbolicLink: candidate) ifTrue: [ ^ false ] ].
 ^ true
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
isSymbolicLink: anEntry
 "Do not traverse links out of the visible directory tree."
 ^ [ (FileIOAccessor default
 primFileAttribute: anEntry pathName asUtf8Bytes
 attributeNumber: 16) = true ] on: Error do: [ :error | true ]
! !


!VisualFileDialogModel methodsFor: 'initialization' stamp: 'VFO 7/Nov/2026 12:00:00'!
topDirectoryWrappers
 topDirectories := {rootDirectory}.
 ^ {VisualFileOutDirectoryWrapper with: rootDirectory name: rootDirectory name model: self}
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
setSelectedDirectoryTo: aWrapper
 (self allowsDirectory: aWrapper withoutListWrapper) ifFalse: [ ^ self ].
 ^ super setSelectedDirectoryTo: aWrapper
! !

!VisualFileDialogModel methodsFor: 'file list' stamp: 'VFO 7/Nov/2026 12:00:00'!
listForSelectingPatterns: selecting rejectingPatterns: rejecting
 ^ (super listForSelectingPatterns: selecting rejectingPatterns: rejecting)
 reject: [ :entry | entry isDirectoryEntry and: [ (self allowsDirectory: entry) not ] ]
! !

!VisualFileDialogModel methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026 12:00:00'!
showHidden
 ^ false
! !

!VisualFileOutDirectoryWrapper methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026 12:00:00'!
contents
 | children |
 children := item directories select: [ :entry | model allowsDirectory: entry ].
 ^ (children asArray sort: [ :a :b | a name caseInsensitiveLessOrEqual: b name ])
 collect: [ :entry | self class with: entry name: entry name model: model ]
! !

!VisualFileDialogModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
postOpen
 topDirectories ifNil: [ self topDirectoryWrappers ].
 ^ super postOpen
! !

!VisualFileOutWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
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

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
buildNavigation
 | row home up location |
 row := LinearLayoutMorph newRow.
 row separation: 6.
 home := self buttonLabel: 'Home' target: model action: #goHome.
 home setBalloonText: 'Go to your home directory'.
 up := self buttonLabel: 'Up' target: model action: #goUp.
 up setBalloonText: 'Go to the parent folder'.
 pathLabel := LabelMorph contents: self displayDirectory.
 pathLabel setBalloonText: model directory pathName.
 location := LinearLayoutMorph newRow.
 location separation: 8; color: self textBackgroundColor;
 borderWidth: 1; borderColor: self widgetsColor.
 location addMorphUseAll: pathLabel.
 row addMorph: home fixedWidth: (self buttonWidthFor: 'Home');
 addMorph: up fixedWidth: (self buttonWidthFor: 'Up');
 addMorph: location proportionalWidth: 1.
 ^ row
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
buildExplorer
 | row files tree |
 row := LinearLayoutMorph newRow.
 files := self morphicFileListPane.
 files menuNshortcutsKey: nil; doubleClickSelector: #enterSelectedDirectory.
 files setBalloonText: 'Double-click to open a folder. Click a file to use its name.'.
 tree := self morphicDirectoryTreePane.
 tree menuNshortcutsKey: nil.
 row addMorph: (self paneTitled: 'Folders' containing: tree) proportionalWidth: 0.32;
 addAdjusterAndMorph: (self paneTitled: 'Files' containing: files) proportionalWidth: 0.68.
 ^ row
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
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

!VisualFileOutWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
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

!VisualFileOutWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
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

!VisualFileDialogWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026 12:00:00'!
displayDirectory
 | parts |
 parts := model directory pathComponents allButFirst: model rootDirectory pathComponents size.
 ^ (String streamContents: [ :stream |
 stream nextPutAll: 'Home'.
 parts do: [ :part | stream nextPutAll: ' / '; nextPutAll: part ] ]) squeezedTo: 72
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
buttonWidthFor: aString
 ^ ((Preferences at: #standardButtonFont) widthOfString: aString) + 32
! !

!VisualFileOut class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026 12:00:00'!
systemCatSingletonMenuSpec
 ^ self fileMenuSpecAt: 65 exportSelector: #visualFileOutSystemCategory
! !

!classDefinition: #VisualFileInModel category: #VisualFileDialogs!
VisualFileDialogModel subclass: #VisualFileInModel
 instanceVariableNames: ''
 classVariableNames: ''
 poolDictionaries: ''
 category: 'VisualFileDialogs'!
!classDefinition: 'VisualFileInModel class' category: #VisualFileDialogs!
VisualFileInModel class instanceVariableNames: ''!

!classDefinition: #VisualFileInWindow category: #VisualFileDialogs!
VisualFileDialogWindow subclass: #VisualFileInWindow
 instanceVariableNames: 'selectionLabel'
 classVariableNames: ''
 poolDictionaries: ''
 category: 'VisualFileDialogs'!
!classDefinition: 'VisualFileInWindow class' category: #VisualFileDialogs!
VisualFileInWindow class instanceVariableNames: ''!

!VisualFileOut class methodsFor: 'opening' stamp: 'VFO 7/Nov/2026 12:00:00'!
openFileIn
 | model |
 model := VisualFileInModel new.
 model restoreDirectory.
 ^ VisualFileInWindow open: model label: 'File In - Open File'
! !


!VisualFileInModel methodsFor: 'file list' stamp: 'VFO 7/Nov/2026 12:00:00'!
listForSelectingPatterns: selecting rejectingPatterns: rejecting
 ^ (super listForSelectingPatterns: selecting rejectingPatterns: rejecting) select: [ :entry |
 entry isDirectoryEntry or: [ self supportsFile: entry ] ]
! !

!VisualFileInModel methodsFor: 'testing' stamp: 'VFO 7/Nov/2026 12:00:00'!
supportsFile: entry
 ^ (#('st' 'cs') includes: entry extension asLowercase)
 and: [ (entry name asLowercase endsWith: '.pck.st') not ]
! !

!VisualFileInModel methodsFor: 'importing' stamp: 'VFO 7/Nov/2026 12:00:00'!
importFileNamed: name
 | file |
 file := self fileNamed: name.
 (self supportsFile: file) ifFalse: [self error: 'Choose a .st or .cs file. Use install package for .pck.st packages.'].
 file exists ifFalse: [self error: 'The selected file does not exist.'].
 (self isSymbolicLink: file) ifTrue: [self error: 'Symbolic links cannot be imported.'].
 ChangeSet fileIn: file.
 self rememberDirectory
! !

!VisualFileInWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
buildHeader
 | header title subtitle |
 header := LinearLayoutMorph newColumn.
 header separation: 4; axisEdgeWeight: #columnTop.
 title := LabelMorph contents: 'Import Code'.
 title emphasis: AbstractFont boldCode.
 subtitle := LabelMorph contents: 'Choose a Smalltalk source file to load into this image.'.
 header addMorphKeepMorphHeight: title; addMorphKeepMorphHeight: subtitle.
 ^ header
! !

!VisualFileInWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
buildActions
 | row hint cancel open |
 row := LinearLayoutMorph newRow.
 row gap: 8.
 hint := LabelMorph contents: 'Smalltalk source (.st, .cs)'.
 cancel := self buttonLabel: 'Cancel' target: self action: #delete.
 open := self buttonLabel: 'File In' target: self action: #importFile.
 open borderWidth: 2; setBalloonText: 'Load the selected source file into this image'.
 row addMorph: hint proportionalWidth: 1;
 addMorph: cancel fixedWidth: (self buttonWidthFor: 'Cancel');
 addMorph: open fixedWidth: (self buttonWidthFor: 'File In').
 ^ row
! !

!VisualFileInWindow methodsFor: 'importing' stamp: 'VFO 7/Nov/2026 12:00:00'!
importFile
 [model importSelectedFile]
 on: Error do: [ :error | ^ self inform: error description ].
 self delete
! !

!VisualFileOut class methodsFor: 'menu & kbd shortcuts' stamp: 'VFO 7/Nov/2026 12:00:00'!
fileMenuSpecAt: position exportSelector: selector
 ^ { {position. 'File Out with Explorer (O)'. $O. #model. selector. #fileOutIcon} }
! !

!VisualFileDialogModel methodsFor: 'validation' stamp: 'VFO 7/Nov/2026 12:00:00'!
fileNamed: name
 (self isValidFileName: name) ifFalse: [self error: 'Enter a valid file name without a path.'].
 (self allowsDirectory: directory) ifFalse: [self error: 'Choose a folder inside your home directory.'].
 ^ directory // name
! !

!VisualFileDialogModel methodsFor: 'validation' stamp: 'VFO 7/Nov/2026 12:00:00'!
isValidFileName: name
 name isEmpty ifTrue: [ ^ false ].
 (#('.' '..') includes: name) ifTrue: [ ^ false ].
 ^ name noneSatisfy: [ :character | '/\:' includes: character ]
! !

!VisualFileDialogWindow methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
enterSelectedDirectory
 "PluggableListMorph sends double-click actions to its containing window."
 ^ model enterSelectedDirectory
! !

!VisualFileOutWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
buildSelectionPane
 ^ self buildFileNamePane
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
buildSelectionPane
 self subclassResponsibility
! !

!VisualFileDialogWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026 12:00:00'!
chooseName: aString
 self subclassResponsibility
! !

!VisualFileInWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
buildSelectionPane
 | pane heading |
 pane := LinearLayoutMorph newColumn.
 pane gap: 6; padding: 8; borderWidth: 1; borderColor: self widgetsColor;
 color: self textBackgroundColor.
 heading := LabelMorph contents: 'Selected file'.
 heading emphasis: AbstractFont boldCode.
 selectionLabel := LabelMorph contents: self selectionText.
 pane addMorphKeepMorphHeight: heading; addMorphUseAll: selectionLabel.
 ^ pane
! !

!VisualFileInWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026 12:00:00'!
chooseName: aString
 selectionLabel ifNotNil: [selectionLabel contents: self selectionText]
! !

!VisualFileInWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026 12:00:00'!
selectionText
 ^ model selectedSourceFile ifNil: ['Select a source file from the list.'] ifNotNil: [:file | file name]
! !

!VisualFileInWindow methodsFor: 'updating' stamp: 'VFO 7/Nov/2026 12:00:00'!
relabel
 super relabel.
 selectionLabel ifNotNil: [selectionLabel contents: self selectionText]
! !

!VisualFileInModel methodsFor: 'accessing' stamp: 'VFO 7/Nov/2026 12:00:00'!
selectedSourceFile
 (listIndex isNil or: [listIndex = 0 or: [listIndex > list size]]) ifTrue: [ ^ nil ].
 (list at: listIndex) isDirectoryEntry ifTrue: [ ^ nil ].
 ^ list at: listIndex
! !

!VisualFileInModel methodsFor: 'importing' stamp: 'VFO 7/Nov/2026 12:00:00'!
importSelectedFile
 | file |
 file := self selectedSourceFile.
 file ifNil: [self error: 'Select a source file from the list.'].
 self importFileNamed: file name
! !

!VisualFileDialogModel methodsFor: 'initialization' stamp: 'VFO 7/Nov/2026 12:00:00'!
directory: aDirectory
 (self allowsDirectory: aDirectory) ifFalse: [ ^ self ].
 listIndex := 0.
 ^ super directory: aDirectory
! !


!VisualFileDialogModel class methodsFor: 'persistence' stamp: 'VFO 7/Nov/2026 12:00:00'!
rememberedDirectoryPath
 LastDirectories ifNil: [LastDirectories := Dictionary new].
 ^ LastDirectories at: self name ifAbsent: [nil]
! !

!VisualFileDialogModel class methodsFor: 'persistence' stamp: 'VFO 7/Nov/2026 12:00:00'!
rememberDirectory: aDirectory
 LastDirectories ifNil: [LastDirectories := Dictionary new].
 LastDirectories at: self name put: aDirectory pathName
! !

!VisualFileDialogModel methodsFor: 'persistence' stamp: 'VFO 7/Nov/2026 12:00:00'!
rememberDirectory
 self class rememberDirectory: directory
! !

!VisualFileDialogModel methodsFor: 'persistence' stamp: 'VFO 7/Nov/2026 12:00:00'!
restoreDirectory
 | path candidate |
 self goHome.
 path := self class rememberedDirectoryPath.
 path isEmptyOrNil ifTrue: [ ^ self ].
 [candidate := path asDirectoryEntry.
 ((self allowsDirectory: candidate) and: [candidate exists])
 ifTrue: [self navigateTo: candidate]] on: Error do: [:error | self goHome]
! !

!VisualFileOut class methodsFor: 'menu-world' stamp: 'VFO 7/Nov/2026 12:00:00'!
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

!WorldMorph methodsFor: 'submorphs-menus' stamp: 'VFO 7/Nov/2026 12:00:00'!
menuNshortcutsSpecsDo: aBlock
 self worldMenuSpec do: aBlock
! !

!VisualFileOut class methodsFor: 'directories' stamp: 'VFO 7/Nov/2026 12:00:00'!
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

!VisualFileOut class methodsFor: 'directories' stamp: 'VFO 7/Nov/2026 12:00:00'!
environmentAt: key
 | raw |
 raw := self primitiveEnvironmentAt: key.
 raw ifNil: [ ^ nil ].
 ^ UnicodeString fromUtf8Bytes: raw asByteArray
! !

!VisualFileOut class methodsFor: 'directories' stamp: 'VFO 7/Nov/2026 12:00:00'!
primitiveEnvironmentAt: key
 "Built-in VM primitive, shared by the Linux, macOS and Windows VMs."
 <primitive: 'primitiveGetenv' module: ''>
 ^ nil
! !

!VisualFileOutWindow methodsFor: 'GUI building' stamp: 'VFO 7/Nov/2026 12:00:00'!
buildNavigation
 | row button |
 row := super buildNavigation.
 button := self buttonLabel: 'New Folder' target: self action: #createDirectory.
 button setBalloonText: 'Create a folder in the current location and open it'.
 row addMorph: button fixedWidth: (self buttonWidthFor: 'New Folder').
 ^ row
! !

!VisualFileOutWindow methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
createDirectory
 | name |
 name := self requestFolderName.
 name ifNil: [ ^ self ].
 [model createDirectoryNamed: name]
 on: Error do: [:error | self inform: error description]
! !

!VisualFileOutModel methodsFor: 'navigation' stamp: 'VFO 7/Nov/2026 12:00:00'!
createDirectoryNamed: proposedName
 | name destination |
 name := proposedName withBlanksTrimmed.
 (self isValidFileName: name) ifFalse: [self error: 'Enter a folder name without a path.'].
 (name beginsWith: '.') ifTrue: [self error: 'Hidden folders cannot be created in this explorer.'].
 ((name anySatisfy: [:character | '<>"|?*' includes: character]) or: [name last = $.])
 ifTrue: [self error: 'Enter a folder name supported by the operating system.'].
 (self allowsDirectory: directory) ifFalse: [self error: 'Choose a folder inside your home directory.'].
 directory invalidateChildren.
 (directory children anySatisfy: [:entry | entry name = name]) ifTrue: [self error: 'A file or folder with that name already exists.'].
 destination := directory / name.
 destination assureExistence.
 destination exists ifFalse: [self error: 'Could not create the folder. Check directory permissions.'].
 self navigateTo: destination.
 ^ destination
! !

!VisualFileOutModel methodsFor: 'exporting' stamp: 'VFD 7/Nov/2026 12:00:00'!
unusedFileWithExtension: extension
 | candidate |
 [candidate := directory // ('VFD-', Time millisecondClockValue asString, '-', 1000000 atRandom asString, extension).
 candidate exists or: [(directory / candidate name) exists]] whileTrue.
 ^ candidate
! !

!VisualFileOutModel methodsFor: 'exporting' stamp: 'VFD 7/Nov/2026 12:00:00'!
renameFile: source to: destination
 source fileAccessor rename: source pathName to: destination pathName.
 source invalidate.
 destination invalidate.
 directory invalidateChildren
! !

!VisualFileOutModel methodsFor: 'exporting' stamp: 'VFD 7/Nov/2026 12:00:00'!
writeFileNamed: name
 | destination temporary backup |
 destination := self fileNamed: name.
 (directory / name) exists ifTrue: [self error: 'The destination is a folder. Choose a file name.'].
 (destination exists and: [self isSymbolicLink: destination]) ifTrue: [self error: 'Symbolic links cannot be overwritten.'].
 temporary := self unusedFileWithExtension: '.tmp'.
 [temporary writeStreamDo: [:stream |
 stream ifNil: [self error: 'Could not create the temporary export file.'].
 self writeOn: stream].
 destination exists ifTrue: [
 backup := self unusedFileWithExtension: '.bak'.
 self renameFile: destination to: backup].
 [self renameFile: temporary to: destination]
 on: Error do: [:commitError |
 backup ifNotNil: [
 [self renameFile: backup to: destination]
 on: Error do: [:restoreError |
 self error: 'Export failed. The original file is preserved at ', backup pathName]].
 commitError pass].
 backup ifNotNil: [[backup delete] on: Error do: [:cleanupError | nil]].
 self rememberDirectory]
 ensure: [[temporary invalidate. temporary exists ifTrue: [temporary delete]]
 on: Error do: [:cleanupError | nil]].
 ^ destination
! !

!VisualFileDialogWindow methodsFor: 'GUI building' stamp: 'VFD 7/Nov/2026 12:00:00'!
initialExtent
 | lineHeight |
 lineHeight := (Preferences at: #standardListFont) lineSpacing.
 ^ ((lineHeight * 40) max: 820) @ ((lineHeight * 24) max: 590)
! !

!VisualFileOutWindow methodsFor: 'dialogs' stamp: 'VFD 7/Nov/2026 12:00:00'!
confirmOverwrite: file
 ^ PopUpMenu confirm: 'The file already exists. Overwrite it?'
! !

!VisualFileOutWindow methodsFor: 'dialogs' stamp: 'VFD 7/Nov/2026 12:00:00'!
requestFolderName
 ^ StringRequestMorph request: 'New folder name' initialAnswer: '' orCancel: [nil]
! !

VisualFileOut initialize!

(CodePackage named: 'VisualFileOut' createIfAbsent: false registerIfNew: false) ifNotNil: [:oldPackage |
 oldPackage includesAnyCode ifFalse: [CodePackage deregister: oldPackage]]!
