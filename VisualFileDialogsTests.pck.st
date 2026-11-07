'From Cuis7.9 [latest update: #8166] on 7 November 2026 at 12:00:00 pm'!
'Description Regression tests for VisualFileDialogs; filesystem fixtures and persistence are isolated from user state.'!
!provides: 'VisualFileDialogsTests' 1 0!
!requires: 'VisualFileDialogs' 1 0 nil!
SystemOrganization addCategory: #VisualFileDialogsTests!

!classDefinition: #VisualFileDialogsTestImportModel category: #VisualFileDialogsTests!
VisualFileInModel subclass: #VisualFileDialogsTestImportModel
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogsTests'!
!classDefinition: 'VisualFileDialogsTestImportModel class' category: #VisualFileDialogsTests!
VisualFileDialogsTestImportModel class instanceVariableNames: ''!

!classDefinition: #VisualFileDialogsTestExportModel category: #VisualFileDialogsTests!
VisualFileOutModel subclass: #VisualFileDialogsTestExportModel
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogsTests'!
!classDefinition: 'VisualFileDialogsTestExportModel class' category: #VisualFileDialogsTests!
VisualFileDialogsTestExportModel class instanceVariableNames: ''!

!classDefinition: #VisualFileDialogsTest category: #VisualFileDialogsTests!
TestCase subclass: #VisualFileDialogsTest
	instanceVariableNames: 'fixture input output windows savedDirectories wasEnabled savedMarker'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogsTests'!
!classDefinition: 'VisualFileDialogsTest class' category: #VisualFileDialogsTests!
VisualFileDialogsTest class instanceVariableNames: ''!


!VisualFileDialogsTest methodsFor: 'fixtures' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
setUp

	super setUp.
	windows := OrderedCollection new.
	savedDirectories := VisualFileDialogModel classPool at: #LastDirectories.
	savedDirectories ifNotNil: [savedDirectories := savedDirectories copy].
	savedMarker := Smalltalk at: #VisualFileDialogsTestMarker ifAbsent: [nil].
	wasEnabled := VisualFileDialogs isEnabled.
	VisualFileDialogs enable.
	fixture := (DirectoryEntry currentDirectory / 'build' / 'test-fixtures') assureExistence / ('VisualFileDialogsTests-', Time millisecondClockValue asString, '-', 1000000 atRandom asString).
	fixture exists ifTrue: [self error: 'Test fixture already exists'].
	fixture assureExistence.
	input := VisualFileDialogsTestImportModel new.
	output := VisualFileDialogsTestExportModel new.
	input goHome; navigateTo: fixture.
	output goHome; navigateTo: fixture; suggestedName: 'export.st' writer: [:stream | stream nextPutAll: 'test contents'].
! !

!VisualFileDialogsTest methodsFor: 'fixtures' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
tearDown

	[windows ifNotNil: [windows do: [:window | window delete]].
		fixture ifNotNil: [fixture recursiveDelete]] ensure: [
		VisualFileDialogModel classPool at: #LastDirectories put: savedDirectories.
		savedMarker ifNil: [Smalltalk removeKey: #VisualFileDialogsTestMarker ifAbsent: []]
			ifNotNil: [Smalltalk at: #VisualFileDialogsTestMarker put: savedMarker].
		VisualFileDialogs isEnabled = wasEnabled ifFalse: [
			wasEnabled
				ifTrue: [VisualFileDialogs enable]
				ifFalse: [VisualFileDialogs disable]].
		super tearDown].
! !

!VisualFileDialogsTest methodsFor: 'helpers' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
writeSource: name contents: contents

	| file |
	file := fixture // name.
	file forceWriteStreamDo: [:stream | stream nextPutAll: contents].
	^ file
! !

!VisualFileDialogsTest methodsFor: 'helpers' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
openWindow: windowClass model: aModel

	| window |
	window := windowClass open: aModel label: 'VisualFileDialogs test'.
	windows add: window.
	^ window
! !

!VisualFileDialogsTest methodsFor: 'helpers' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
select: label in: aModel

	| index |
	index := aModel fileList indexOf: label.
	index = 0 ifTrue: [self error: 'The fixture does not contain the requested entry: ', label].
	aModel fileListIndex: index
! !

!VisualFileDialogsTest methodsFor: 'helpers' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
folder: name

	^ (fixture / name) assureExistence
! !


!classDefinition: #VisualFileDialogsTestFailingExportModel category: #VisualFileDialogsTests!
VisualFileDialogsTestExportModel subclass: #VisualFileDialogsTestFailingExportModel
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogsTests'!
!classDefinition: 'VisualFileDialogsTestFailingExportModel class' category: #VisualFileDialogsTests!
VisualFileDialogsTestFailingExportModel class instanceVariableNames: ''!
!VisualFileDialogsTestFailingExportModel methodsFor: 'exporting' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
renameFile: source to: destination

	(source name endsWith: '.tmp') ifTrue: [self error: 'Simulated commit failure'].
	^ super renameFile: source to: destination
! !


!classDefinition: #VisualFileDialogsTestExportWindow category: #VisualFileDialogsTests!
VisualFileOutWindow subclass: #VisualFileDialogsTestExportWindow
	instanceVariableNames: 'overwriteAnswer folderAnswer'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogsTests'!
!classDefinition: 'VisualFileDialogsTestExportWindow class' category: #VisualFileDialogsTests!
VisualFileDialogsTestExportWindow class instanceVariableNames: ''!
!VisualFileDialogsTestExportWindow methodsFor: 'dialogs' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
confirmOverwrite: file

	^ overwriteAnswer = true
! !
!VisualFileDialogsTestExportWindow methodsFor: 'dialogs' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
overwriteAnswer: answer

	overwriteAnswer := answer
! !
!VisualFileDialogsTestExportWindow methodsFor: 'dialogs' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
requestFolderName

	^ folderAnswer
! !
!VisualFileDialogsTestExportWindow methodsFor: 'dialogs' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
folderAnswer: answer

	folderAnswer := answer
! !


!classDefinition: #VisualFileDialogsTestRecoveryFailureModel category: #VisualFileDialogsTests!
VisualFileDialogsTestFailingExportModel subclass: #VisualFileDialogsTestRecoveryFailureModel
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogsTests'!
!classDefinition: 'VisualFileDialogsTestRecoveryFailureModel class' category: #VisualFileDialogsTests!
VisualFileDialogsTestRecoveryFailureModel class instanceVariableNames: ''!
!VisualFileDialogsTestRecoveryFailureModel methodsFor: 'exporting' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
renameFile: source to: destination

	(source name endsWith: '.bak') ifTrue: [self error: 'Simulated recovery failure'].
	^ super renameFile: source to: destination
! !


!classDefinition: #VisualFileDialogsTestLinkedImportModel category: #VisualFileDialogsTests!
VisualFileDialogsTestImportModel subclass: #VisualFileDialogsTestLinkedImportModel
	instanceVariableNames: 'linkedEntry'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogsTests'!
!VisualFileDialogsTestLinkedImportModel methodsFor: 'testing' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
linkedEntry: entry

	linkedEntry := entry
! !
!VisualFileDialogsTestLinkedImportModel methodsFor: 'navigation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
isSymbolicLink: entry

	entry = linkedEntry ifTrue: [ ^ true ].
	^ super isSymbolicLink: entry
! !

!classDefinition: #VisualFileDialogsTestLinkedExportModel category: #VisualFileDialogsTests!
VisualFileDialogsTestExportModel subclass: #VisualFileDialogsTestLinkedExportModel
	instanceVariableNames: 'linkedEntry'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'VisualFileDialogsTests'!
!VisualFileDialogsTestLinkedExportModel methodsFor: 'testing' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
linkedEntry: entry

	linkedEntry := entry
! !
!VisualFileDialogsTestLinkedExportModel methodsFor: 'navigation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
isSymbolicLink: entry

	entry = linkedEntry ifTrue: [ ^ true ].
	^ super isSymbolicLink: entry
! !


!VisualFileDialogsTest methodsFor: 'helpers' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
errorDuring: aBlock

	^ [aBlock value. nil] on: Error do: [:error | error]
! !


!VisualFileDialogsTest methodsFor: 'helpers' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
invalidFileNames

	^ #('' '.' '..' '../escape.st' 'a/b.st' 'a\b.st' 'drive:file.st'
		'bad?' 'bad*' 'bad<' 'bad>' 'bad"' 'bad|' 'bad.' 'bad '
		'CON' 'nul.st' 'COM1.st' 'LPT9'),
		{ 'bad', (String with: Character null), '.st' }
! !

!VisualFileDialogsTest methodsFor: 'tests - navigation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test01HomeStopsUpwardNavigation

	input goHome; goUp.

	self assert: input directory = input rootDirectory.
! !

!VisualFileDialogsTest methodsFor: 'tests - navigation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test02RejectedDirectoriesLeaveTheCurrentLocationUnchanged

	| cases results |

	cases := {
		{'navigate outside home'. #navigateTo:. input rootDirectory parent}.
		{'set directory outside home'. #directory:. input rootDirectory parent}.
		{'navigate to hidden folder'. #navigateTo:. self folder: '.hidden'}}.

	results := cases collect: [:each |
		input perform: each second with: each third.
		{each first. input directory}].

	results do: [:each |
		self assert: each second = fixture description: each first].
! !


!VisualFileDialogsTest methodsFor: 'tests - navigation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test03HiddenFoldersAreFilteredFromBothViews

	| wrapper |
	self folder: '.hidden'.
	self folder: 'Visible'.
	output navigateTo: fixture.
	wrapper := VisualFileDialogsDirectoryWrapper with: fixture name: fixture name model: output.

	self deny: (output fileList includes: '.hidden /').
	self assert: (output fileList includes: 'Visible /').
	self assert: (wrapper contents collect: [:each | each asString]) = #('Visible').
! !


!VisualFileDialogsTest methodsFor: 'tests - navigation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test04TreeHasOnlyHomeAsItsRoot

	| roots |
	roots := input topDirectoryWrappers.

	self assert: roots size = 1.
	self assert: roots first withoutListWrapper = input rootDirectory.
! !

!VisualFileDialogsTest methodsFor: 'tests - navigation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test05NavigationClearsImportSelection

	| selectedBeforeNavigation other |

	self writeSource: 'code.st' contents: ''.
	other := self folder: 'Other'.
	input navigateTo: fixture.
	self select: 'code.st' in: input.
	selectedBeforeNavigation := input selectedSourceFile.

	input navigateTo: other.

	self assert: selectedBeforeNavigation notNil.
	self assert: input selectedSourceFile isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests - navigation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test06DoubleClickOpensSelectedFolderInBothDialogs

	| folder cases results |

	folder := self folder: 'Child'.
	cases := {{VisualFileInWindow. input}. {VisualFileOutWindow. output}}.

	results := cases collect: [:each |
		| window |
		window := self openWindow: each first model: each second.
		self select: 'Child /' in: each second.
		window enterSelectedDirectory.
		{each first name. each second directory}].

	results do: [:each |
		self assert: each second = folder description: each first].
! !


!VisualFileDialogsTest methodsFor: 'tests - navigation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test07EmptyTreeSelectionIsIgnored

	input setSelectedDirectoryTo: nil.

	self deny: (input allowsDirectory: nil).
	self assert: input directory = fixture.
! !

!VisualFileDialogsTest methodsFor: 'tests - navigation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test08LinkedDirectoryAndItsDescendantsCannotBeOpened

	| linked folder destinations results |

	folder := self folder: 'Linked'.
	(folder / 'Child') assureExistence.
	linked := VisualFileDialogsTestLinkedImportModel new.
	linked goHome; navigateTo: fixture; linkedEntry: folder.
	destinations := {folder. folder / 'Child'}.

	results := destinations collect: [:destination |
		linked navigateTo: destination.
		{destination pathName. linked directory}].

	results do: [:each |
		self assert: each second = fixture description: each first].
! !


!VisualFileDialogsTest methodsFor: 'tests - navigation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test09LinkedDirectoriesAreHiddenFromListAndTree

	| linked folder wrapper |

	folder := self folder: 'Linked'.
	(folder / 'Child') assureExistence.
	linked := VisualFileDialogsTestLinkedImportModel new.
	linked goHome; navigateTo: fixture; linkedEntry: folder.

	linked navigateTo: fixture.
	wrapper := VisualFileDialogsDirectoryWrapper with: fixture name: fixture name model: linked.

	self deny: (linked fileList includes: 'Linked /').
	self deny: (wrapper contents anySatisfy: [:each | each withoutListWrapper = folder]).
! !


!VisualFileDialogsTest methodsFor: 'tests - validation' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test10FileNameValidationAcceptsUnicode

	| valid |

	valid := output isValidFileName: 'Código válido.st'.

	self assert: valid.
! !

!VisualFileDialogsTest methodsFor: 'tests - folders' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test11FolderCreationNavigatesWithoutChangingExportNameOrRememberedLocation

	| folder |
	folder := output createDirectoryNamed: 'New folder á'.

	self assert: folder exists.
	self assert: output directory = folder.
	self assert: output suggestedName = 'export.st'.
	self assert: output class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests - folders' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test12RejectedFolderNamesLeaveFilesystemAndLocationUnchanged

	| names results |

	names := (self invalidFileNames reject: [:name | name = 'bad ']), #('.hidden').

	results := names collect: [:name |
		| error |
		error := self errorDuring: [output createDirectoryNamed: name].
		{name printString. error. output directory}].

	results do: [:each |
		self assert: (each second isKindOf: Error) description: each first.
		self assert: each third = fixture description: each first].
	self assert: fixture children isEmpty.
! !

!VisualFileDialogsTest methodsFor: 'tests - folders' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test13FolderCreationRejectsExistingEntriesWithoutChangingThem

	| folder file cases results |

	folder := self folder: 'Existing folder'.
	file := self writeSource: 'Existing file' contents: 'keep'.
	cases := {folder. file}.

	results := cases collect: [:entry |
		| error |
		error := self errorDuring: [output createDirectoryNamed: entry name].
		{entry name. error. output directory}].

	results do: [:each |
		self assert: (each second isKindOf: Error) description: each first.
		self assert: each second messageText = 'A file or folder with that name already exists.' description: each first.
		self assert: each third = fixture description: each first].
	self assert: folder exists.
	self assert: folder children isEmpty.
	self assert: file textContents = 'keep'.
! !


!VisualFileDialogsTest methodsFor: 'tests - folders' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test14CancellingNewFolderDoesNotCreateAnything

	| window |
	window := self openWindow: VisualFileDialogsTestExportWindow model: output.
	window createDirectory.

	self assert: fixture children isEmpty.
	self assert: output directory = fixture.
! !

!VisualFileDialogsTest methodsFor: 'tests - folders' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test15NewFolderDialogCreatesAndOpensFolder

	| window |
	window := self openWindow: VisualFileDialogsTestExportWindow model: output.
	window folderAnswer: 'UI Folder'.
	window createDirectory.

	self assert: output directory = (fixture / 'UI Folder').
	self assert: output directory exists.
! !


!VisualFileDialogsTest methodsFor: 'tests - import' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test16ImportListFiltersUnsupportedFilesAndPackages

	self writeSource: 'code.st' contents: ''.
	self writeSource: 'changes.cs' contents: ''.
	self writeSource: 'Parser-SourceDelta-SyntaxError-Fix.cs.st' contents: ''.
	self writeSource: 'package.pck.st' contents: ''.
	self writeSource: 'notes.txt' contents: ''.
	self folder: 'Folder'.
	input navigateTo: fixture.

	self assert: (input fileList includes: 'code.st').
	self assert: (input fileList includes: 'changes.cs').
	self assert: (input fileList includes: 'Parser-SourceDelta-SyntaxError-Fix.cs.st').
	self assert: (input fileList includes: 'Folder /').
	self deny: (input fileList includes: 'package.pck.st').
	self deny: (input fileList includes: 'notes.txt').
! !

!VisualFileDialogsTest methodsFor: 'tests - import' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test17ImportRequiresAnExistingSelectedSource

	| cases results |

	cases := {
		{'no selection'. [input importSelectedFile]. 'Select a source file from the list.'}.
		{'missing file'. [input importFileNamed: 'missing.st']. 'The selected file does not exist.'}}.

	results := cases collect: [:each |
		{each first. self errorDuring: each second. each third. input class rememberedDirectoryPath}].

	results do: [:each |
		self assert: (each second isKindOf: Error) description: each first.
		self assert: each second messageText = each third description: each first.
		self assert: each fourth isNil description: each first].
! !


!VisualFileDialogsTest methodsFor: 'tests - import' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test18WindowDoubleClickOnFileDoesNotImport

	| window |
	self writeSource: 'code.st' contents: 'Smalltalk at: #VisualFileDialogsTestMarker put: 42!!'.
	input navigateTo: fixture.
	window := self openWindow: VisualFileInWindow model: input.
	self select: 'code.st' in: input.
	window enterSelectedDirectory.

	self assert: input directory = fixture.
	self assert: (Smalltalk at: #VisualFileDialogsTestMarker ifAbsent: [nil]) = savedMarker.
! !

!VisualFileDialogsTest methodsFor: 'tests - import' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test19ImportWindowLoadsSourceClosesAndRemembersOnlyItsOwnDirectory

	| window |
	self writeSource: 'code.st' contents: 'Smalltalk at: #VisualFileDialogsTestMarker put: 42!!'.
	input navigateTo: fixture.
	window := self openWindow: VisualFileInWindow model: input.
	self select: 'code.st' in: input.
	window importFile.

	self assert: (Smalltalk at: #VisualFileDialogsTestMarker) = 42.
	self assert: window owner isNil.
	self assert: input class rememberedDirectoryPath = fixture pathName.
	self assert: output class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests - import' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test20LinkedSourceCannotBeImported

	| linked file |
	file := self writeSource: 'linked.st' contents: 'Smalltalk at: #VisualFileDialogsTestMarker put: 42!!'.
	linked := VisualFileDialogsTestLinkedImportModel new.
	linked goHome; navigateTo: fixture; linkedEntry: file.

	self should: [linked importFileNamed: file name] raise: Error.
	self assert: (Smalltalk at: #VisualFileDialogsTestMarker ifAbsent: [nil]) = savedMarker.
! !

!VisualFileDialogsTest methodsFor: 'tests - export' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test21ExportWritesContentsClosesAndRemembersDirectory

	| window |
	window := self openWindow: VisualFileOutWindow model: output.
	window saveFile.

	self assert: (fixture // 'export.st') textContents = 'test contents'.
	self assert: window owner isNil.
	self assert: output class rememberedDirectoryPath = fixture pathName.
	self assert: input class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests - export' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test22ExportReplacesExistingFileAfterCompleteWrite

	| contentsDuringWrite |

	self writeSource: 'existing.st' contents: 'original'.
	output suggestedName: 'existing.st' writer: [:stream |
		contentsDuringWrite := (fixture // 'existing.st') textContents.
		stream nextPutAll: 'replacement'].

	output writeFileNamed: 'existing.st'.

	self assert: contentsDuringWrite = 'original'.
	self assert: (fixture // 'existing.st') textContents = 'replacement'.
	self assert: fixture children size = 1.
! !

!VisualFileDialogsTest methodsFor: 'tests - export' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test23WriterFailurePreservesExistingFileAndState

	self writeSource: 'existing.st' contents: 'original'.
	output suggestedName: 'existing.st' writer: [:stream | stream nextPutAll: 'partial'. self error: 'Simulated writer failure'].

	self should: [output writeFileNamed: 'existing.st'] raise: Error.
	self assert: (fixture // 'existing.st') textContents = 'original'.
	self assert: fixture children size = 1.
	self assert: output class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests - export' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test24WriterFailureDoesNotCreateDestination

	output suggestedName: 'new.st' writer: [:stream | stream nextPutAll: 'partial'. self error: 'Simulated writer failure'].

	self should: [output writeFileNamed: 'new.st'] raise: Error.
	self assert: fixture children isEmpty.
! !

!VisualFileDialogsTest methodsFor: 'tests - export' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test25CommitFailureRestoresOriginalFile

	| failing |
	self writeSource: 'existing.st' contents: 'original'.
	failing := VisualFileDialogsTestFailingExportModel new.
	failing goHome; navigateTo: fixture; suggestedName: 'existing.st' writer: [:stream | stream nextPutAll: 'replacement'].

	self should: [failing writeFileNamed: 'existing.st'] raise: Error.
	self assert: (fixture // 'existing.st') textContents = 'original'.
	self assert: fixture children size = 1.
	self assert: failing class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests - export' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test26ExportRejectsExistingFolder

	self folder: 'folder.st'.

	self should: [output writeFileNamed: 'folder.st'] raise: Error.
	self assert: (fixture / 'folder.st') exists.
! !

!VisualFileDialogsTest methodsFor: 'tests - export' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test27DecliningOverwritePreservesFileAndOpenDialog

	| window |
	self writeSource: 'export.st' contents: 'original'.
	window := self openWindow: VisualFileDialogsTestExportWindow model: output.
	window saveFile.

	self assert: (fixture // 'export.st') textContents = 'original'.
	self assert: window owner notNil.
	self assert: output class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests - export' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test28AcceptingOverwriteWritesAndClosesDialog

	| window |
	self writeSource: 'export.st' contents: 'original'.
	window := self openWindow: VisualFileDialogsTestExportWindow model: output.
	window overwriteAnswer: true.
	window saveFile.

	self assert: (fixture // 'export.st') textContents = 'test contents'.
	self assert: window owner isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests - export' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test29RecoveryFailureRetainsBackupAndReportsItsPath

	| failing backups error |

	self writeSource: 'existing.st' contents: 'original'.
	failing := VisualFileDialogsTestRecoveryFailureModel new.
	failing goHome; navigateTo: fixture; suggestedName: 'existing.st' writer: [:stream | stream nextPutAll: 'replacement'].

	error := self errorDuring: [failing writeFileNamed: 'existing.st'].
	backups := fixture files select: [:file | file name endsWith: '.bak'].

	self assert: (error isKindOf: Error).
	self assert: backups size = 1.
	self assert: (error messageText includesSubString: backups first pathName).
	self assert: backups first textContents = 'original'.
	self assert: fixture children size = 1.
	self assert: failing class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests - export' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test30ExportRejectsUnsupportedNames

	| results |

	results := self invalidFileNames collect: [:name |
		{name printString. self errorDuring: [output writeFileNamed: name]}].

	results do: [:each |
		self assert: (each second isKindOf: Error) description: each first].
	self assert: fixture children isEmpty.
! !

!VisualFileDialogsTest methodsFor: 'tests - export' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test31LinkedExportDestinationIsRejectedBeforeWriting

	| linked writerWasCalled error |

	self writeSource: 'linked.st' contents: 'original'.
	writerWasCalled := false.
	linked := VisualFileDialogsTestLinkedExportModel new.
	linked goHome; navigateTo: fixture;
		suggestedName: 'linked.st' writer: [:stream | writerWasCalled := true];
		linkedEntry: fixture // 'linked.st'.

	error := self errorDuring: [linked writeFileNamed: 'linked.st'].

	self assert: (error isKindOf: Error).
	self assert: error messageText = 'Symbolic links cannot be overwritten.'.
	self deny: writerWasCalled.
	self assert: (fixture // 'linked.st') textContents = 'original'.
! !

!VisualFileDialogsTest methodsFor: 'tests - persistence' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test32ImageStateIsIndependentAcrossModelInstances

	| other |
	other := self folder: 'Other'.
	input rememberDirectory.
	output navigateTo: other; rememberDirectory.
	input := VisualFileDialogsTestImportModel new.
	output := VisualFileDialogsTestExportModel new.
	input goHome; restoreDirectory.
	output goHome; restoreDirectory.

	self assert: input directory = fixture.
	self assert: output directory = other.
! !

!VisualFileDialogsTest methodsFor: 'tests - persistence' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test33UnusableRememberedDirectoriesFallBackToHome

	| cases results |

	cases := {
		{'missing directory'. (fixture / 'Missing') pathName}.
		{'outside home'. input rootDirectory parent pathName}.
		{'corrupt path'. 'not-an-absolute-path'}}.

	results := cases collect: [:each |
		VisualFileDialogModel classPool at: #LastDirectories put:
			(Dictionary new at: input class name put: each second; yourself).
		input restoreDirectory.
		{each first. input directory}].

	results do: [:each |
		self assert: each second = input rootDirectory description: each first].
! !


!VisualFileDialogsTest methodsFor: 'tests - persistence' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test34CancelDoesNotPersistNavigation

	| window |
	input rememberDirectory.
	window := self openWindow: VisualFileInWindow model: input.
	input navigateTo: (self folder: 'Other').
	window delete.
	input restoreDirectory.

	self assert: input directory = fixture.
! !

!VisualFileDialogsTest methodsFor: 'tests - persistence' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test35RememberingDirectoriesDoesNotWriteExternalFiles

	input rememberDirectory.
	output rememberDirectory.

	self assert: fixture children isEmpty.
! !

!VisualFileDialogsTest methodsFor: 'tests - persistence' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test36ClearedRememberedDirectoriesRestoreHome

	input rememberDirectory.
	output rememberDirectory.
	VisualFileDialogModel classPool at: #LastDirectories put: nil.

	input restoreDirectory.
	output restoreDirectory.

	self assert: input directory = input rootDirectory.
	self assert: output directory = output rootDirectory.
! !

!VisualFileDialogsTest methodsFor: 'tests - menus' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test37WorldMenuHasFileInWithoutKeyboardShortcut

	| spec |
	spec := VisualFileDialogs worldMenuOptions first.

	self assert: (spec at: #label) = 'File In with Explorer'.
	self assert: (spec at: #selector) = #openFileIn.
	self assert: (TheWorldMenu new buildWorldMenu items anySatisfy: [:item | item contents = 'File In with Explorer']).
	self deny: (WorldMorph new allMenuNshortcutsSpecs values anySatisfy: [:each | each size >= 5 and: [each fifth = #openFileIn]]).
! !

!VisualFileDialogsTest methodsFor: 'tests - menus' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test38BrowserExportMenusProvideShortcutAndSupportedActions

	| specs |

	specs := #(systemCatListMenuSpec systemCatSingletonMenuSpec classListMenuSpec messageCatListMenuSpec messageListMenuSpec)
		collect: [:key | VisualFileDialogs perform: key].

	specs do: [:spec |
		self assert: spec size = 1.
		self assert: spec first third = $O.
		self assert: (Browser canUnderstand: spec first fifth)].
! !

!VisualFileDialogsTest methodsFor: 'tests - menus' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test39BrowserExportMenuPreservesInheritedShortcut

	| inheritedSpec |

	inheritedSpec := BrowserWindow new messageListMenuSpec detect: [:each | each first = 130].

	self assert: inheritedSpec third = $i.
! !

!VisualFileDialogsTest methodsFor: 'tests - menus' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test40DisabledPackageHidesWorldEntry

	VisualFileDialogs disable.

	self assert: VisualFileDialogs worldMenuOptions isEmpty.
! !

!VisualFileDialogsTest methodsFor: 'tests - home resolution' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test41HomeResolutionUsesPlatformEnvironmentAndWindowsFallback

	| windowsEnvironment cases results |

	windowsEnvironment := Dictionary new
		at: 'USERPROFILE' put: 'D:\Profiles\User';
		at: 'HOMEDRIVE' put: 'E:';
		at: 'HOMEPATH' put: '\Homes\User';
		yourself.
	cases := {
		{'Linux HOME'. 'Linux'. Dictionary new at: 'HOME' put: '/custom/Home Folder'; yourself. '/custom/Home Folder'}.
		{'macOS HOME'. 'Mac OS'. Dictionary new at: 'HOME' put: '/custom/Home Folder'; yourself. '/custom/Home Folder'}.
		{'Windows USERPROFILE precedence'. 'Win32'. windowsEnvironment. 'D:\Profiles\User'}.
		{'Windows drive and path fallback'. 'Win32'. windowsEnvironment copy removeKey: 'USERPROFILE'; yourself. 'E:\Homes\User'}.
		{'Windows without environment'. 'Win32'. Dictionary new. nil}}.

	results := cases collect: [:each |
		| home |
		home := VisualFileDialogs homePathFor: each second environment: [:key |
			each third at: key ifAbsent: [nil]].
		{each first. home. each fourth}].

	results do: [:each |
		self assert: each second = each third description: each first].
! !


!VisualFileDialogsTest methodsFor: 'tests - window layout' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
test42InitialExtentMeetsMinimumSizeAndListFontHeight

	| extent |
	extent := VisualFileOutWindow new initialExtent.

	self assert: extent x >= 820.
	self assert: extent y >= ((Preferences at: #standardListFont) lineSpacing * 24).
! !
