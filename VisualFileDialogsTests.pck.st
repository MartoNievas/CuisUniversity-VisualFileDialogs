'From Cuis7.9 [latest update: #8166] on 7 November 2026 at 12:00:00 pm'!
'Description Regression tests for VisualFileDialogs; filesystem fixtures and persistence are isolated from user state.'!
!provides: 'VisualFileDialogsTests' 1 2!
!requires: 'VisualFileDialogs' 1 6 nil!
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
 wasEnabled = false ifTrue: [VisualFileDialogs disable].
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
 self assert: index > 0.
 aModel fileListIndex: index
! !

!VisualFileDialogsTest methodsFor: 'helpers' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
folder: name
 ^ (fixture / name) assureExistence
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testImportAndExportHaveIndependentBaseClasses
 self assert: VisualFileInModel superclass = VisualFileDialogModel.
 self assert: VisualFileOutModel superclass = VisualFileDialogModel.
 self assert: VisualFileInWindow superclass = VisualFileDialogWindow.
 self deny: (input respondsTo: #writeOn:).
 self deny: (VisualFileInWindow canUnderstand: #saveFile).
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testHomeStopsUpwardNavigation
 input goHome; goUp.
 self assert: input directory = input rootDirectory.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testOutsideHomeCannotBeNavigatedTo
 input navigateTo: input rootDirectory parent.
 self assert: input directory = fixture.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testDirectorySetterCannotEscapeHome
 input directory: input rootDirectory parent.
 self assert: input directory = fixture.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testHiddenFoldersAreFilteredFromBothViews
 | wrapper |
 self folder: '.hidden'.
 self folder: 'Visible'.
 output navigateTo: fixture.
 self deny: (output fileList includes: '.hidden /').
 self assert: (output fileList includes: 'Visible /').
 wrapper := VisualFileDialogsDirectoryWrapper with: fixture name: fixture name model: output.
 self assert: (wrapper contents collect: [:each | each asString]) = #('Visible').
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testHiddenFolderCannotBeOpenedDirectly
 input navigateTo: (self folder: '.hidden').
 self assert: input directory = fixture.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testTreeHasOnlyHomeAsItsRoot
 | roots |
 roots := input topDirectoryWrappers.
 self assert: roots size = 1.
 self assert: roots first withoutListWrapper = input rootDirectory.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testInvalidFileNamesAreRejected
 #('' '.' '..' '../escape.st' 'a/b.st' 'a\b.st' 'drive:file.st') do: [:name |
 self deny: (output isValidFileName: name).
 self should: [output fileNamed: name] raise: Error].
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testFolderCreationNavigatesAndPreservesExportName
 | folder |
 folder := output createDirectoryNamed: 'New folder á'.
 self assert: folder exists.
 self assert: output directory = folder.
 self assert: output suggestedName = 'export.st'.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testInvalidFolderNamesDoNotChangeLocation
 #('' '.' '..' '.hidden' '../escape' 'a/b' 'a\b' 'bad:name' 'bad?' 'bad.') do: [:name |
 self should: [output createDirectoryNamed: name] raise: Error.
 self assert: output directory = fixture].
 self assert: fixture children isEmpty.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testFolderCreationRejectsExistingDirectory
 self folder: 'Existing'.
 self should: [output createDirectoryNamed: 'Existing'] raise: Error.
 self assert: output directory = fixture.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testFolderCreationRejectsExistingFile
 self writeSource: 'Existing' contents: 'keep'.
 self should: [output createDirectoryNamed: 'Existing'] raise: Error.
 self assert: (fixture // 'Existing') textContents = 'keep'.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testCreatingFolderDoesNotRememberExportLocation
 output createDirectoryNamed: 'New'.
 self assert: output class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testImportListFiltersUnsupportedFilesAndPackages
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

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testImportRequiresAnExistingSelectedFile
 self should: [input importSelectedFile] raise: Error.
 self should: [input importFileNamed: 'missing.st'] raise: Error.
 self assert: input class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testNavigationClearsImportSelection
 self writeSource: 'code.st' contents: ''.
 input navigateTo: fixture.
 self select: 'code.st' in: input.
 self assert: input selectedSourceFile notNil.
 input navigateTo: (self folder: 'Other').
 self assert: input selectedSourceFile isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testImportLoadsCodeAndRemembersOnlyItsOwnDirectory
 self writeSource: 'code.st' contents: 'Smalltalk at: #VisualFileDialogsTestMarker put: 42!!'.
 input importFileNamed: 'code.st'.
 self assert: (Smalltalk at: #VisualFileDialogsTestMarker) = 42.
 self assert: input class rememberedDirectoryPath = fixture pathName.
 self assert: output class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testImageStateIsIndependentAcrossModelInstances
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

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testRestoreMissingDirectoryFallsBackToHome
 input class rememberDirectory: fixture / 'Missing'.
 input restoreDirectory.
 self assert: input directory = input rootDirectory.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testRestoreOutsideHomeFallsBackToHome
 input class rememberDirectory: input rootDirectory parent.
 input restoreDirectory.
 self assert: input directory = input rootDirectory.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testRestoreCorruptStateFallsBackToHome
 VisualFileDialogModel classPool at: #LastDirectories put: (Dictionary new at: input class name put: 'not-an-absolute-path'; yourself).
 input restoreDirectory.
 self assert: input directory = input rootDirectory.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testCancelDoesNotPersistNavigation
 | window |
 input rememberDirectory.
 window := self openWindow: VisualFileInWindow model: input.
 input navigateTo: (self folder: 'Other').
 window delete.
 input restoreDirectory.
 self assert: input directory = fixture.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testWindowDoubleClickOnFileDoesNotImport
 | window |
 self writeSource: 'code.st' contents: 'Smalltalk at: #VisualFileDialogsTestMarker put: 42!!'.
 input navigateTo: fixture.
 window := self openWindow: VisualFileInWindow model: input.
 self select: 'code.st' in: input.
 window enterSelectedDirectory.
 self assert: input directory = fixture.
 self assert: (Smalltalk at: #VisualFileDialogsTestMarker ifAbsent: [nil]) = savedMarker.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testWindowDoubleClickOpensFoldersInBothDialogs
 | window folder |
 folder := self folder: 'Child'.
 { {VisualFileInWindow. input}. {VisualFileOutWindow. output} } do: [:pair |
 pair second navigateTo: fixture.
 window := self openWindow: pair first model: pair second.
 self select: 'Child /' in: pair second.
 window enterSelectedDirectory.
 self assert: pair second directory = folder].
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testExportWritesContentsClosesAndRemembersDirectory
 | window |
 window := self openWindow: VisualFileOutWindow model: output.
 window saveFile.
 self assert: (fixture // 'export.st') textContents = 'test contents'.
 self assert: window owner isNil.
 self assert: output class rememberedDirectoryPath = fixture pathName.
 self assert: input class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testImportWindowLoadsSelectedFileAndCloses
 | window |
 self writeSource: 'code.st' contents: 'Smalltalk at: #VisualFileDialogsTestMarker put: 42!!'.
 input navigateTo: fixture.
 window := self openWindow: VisualFileInWindow model: input.
 self select: 'code.st' in: input.
 window importFile.
 self assert: (Smalltalk at: #VisualFileDialogsTestMarker) = 42.
 self assert: window owner isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testWorldMenuHasFileInWithoutKeyboardShortcut
 | spec |
 spec := VisualFileDialogs worldMenuOptions first.
 self assert: (spec at: #label) = 'File In with Explorer'.
 self assert: (spec at: #selector) = #openFileIn.
 self assert: (TheWorldMenu new buildWorldMenu items anySatisfy: [:item | item contents = 'File In with Explorer']).
 self deny: (WorldMorph new allMenuNshortcutsSpecs values anySatisfy: [:each | each size >= 5 and: [each fifth = #openFileIn]]).
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testBrowserMenusContainOnlyExportAndPreserveInheritance
 | spec |
 #(systemCatListMenuSpec systemCatSingletonMenuSpec classListMenuSpec messageCatListMenuSpec messageListMenuSpec) do: [:key |
 spec := VisualFileDialogs perform: key.
 self assert: spec size = 1.
 self assert: spec first third = $O.
 self assert: (Browser canUnderstand: spec first fifth)].
 spec := BrowserWindow new messageListMenuSpec detect: [:each | each first = 130].
 self assert: spec third = $i.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testDisabledPackageHidesWorldEntry
 VisualFileDialogs disable.
 self assert: VisualFileDialogs worldMenuOptions isEmpty.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testHomeResolutionUsesPlatformEnvironment
 | environment lookup |
 environment := Dictionary new.
 environment at: 'HOME' put: '/custom/Home Folder'; at: 'USERPROFILE' put: 'D:\Profiles\User'; at: 'HOMEDRIVE' put: 'E:'; at: 'HOMEPATH' put: '\Homes\User'.
 lookup := [:key | environment at: key ifAbsent: [nil]].
 #('Linux' 'Mac OS') do: [:platform | self assert: (VisualFileDialogs homePathFor: platform environment: lookup) = '/custom/Home Folder'].
 self assert: (VisualFileDialogs homePathFor: 'Win32' environment: lookup) = 'D:\Profiles\User'.
 environment removeKey: 'USERPROFILE'.
 self assert: (VisualFileDialogs homePathFor: 'Win32' environment: lookup) = 'E:\Homes\User'.
 self assert: (VisualFileDialogs homePathFor: 'Win32' environment: [:key | nil]) isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testEmptyTreeSelectionIsIgnored
 self deny: (input allowsDirectory: nil).
 input setSelectedDirectoryTo: nil.
 self assert: input directory = fixture.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testRememberedFoldersHaveNoExternalPersistence
 input rememberDirectory.
 output rememberDirectory.
 self assert: fixture children isEmpty.
 self deny: (input class respondsTo: #directoryStateFile).
 VisualFileDialogModel classPool at: #LastDirectories put: nil.
 input restoreDirectory.
 output restoreDirectory.
 self assert: input directory = input rootDirectory.
 self assert: output directory = output rootDirectory.
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

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testExportReplacesExistingFileAfterCompleteWrite
 self writeSource: 'existing.st' contents: 'original'.
 output writeFileNamed: 'existing.st'.
 self assert: (fixture // 'existing.st') textContents = 'test contents'.
 self assert: fixture children size = 1.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testWriterFailurePreservesExistingFileAndState
 self writeSource: 'existing.st' contents: 'original'.
 output suggestedName: 'existing.st' writer: [:stream | stream nextPutAll: 'partial'. self error: 'Simulated writer failure'].
 self should: [output writeFileNamed: 'existing.st'] raise: Error.
 self assert: (fixture // 'existing.st') textContents = 'original'.
 self assert: fixture children size = 1.
 self assert: output class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testWriterFailureDoesNotCreateDestination
 output suggestedName: 'new.st' writer: [:stream | stream nextPutAll: 'partial'. self error: 'Simulated writer failure'].
 self should: [output writeFileNamed: 'new.st'] raise: Error.
 self assert: fixture children isEmpty.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testCommitFailureRestoresOriginalFile
 | failing |
 self writeSource: 'existing.st' contents: 'original'.
 failing := VisualFileDialogsTestFailingExportModel new.
 failing goHome; navigateTo: fixture; suggestedName: 'existing.st' writer: [:stream | stream nextPutAll: 'replacement'].
 self should: [failing writeFileNamed: 'existing.st'] raise: Error.
 self assert: (fixture // 'existing.st') textContents = 'original'.
 self assert: fixture children size = 1.
 self assert: failing class rememberedDirectoryPath isNil.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testExportRejectsExistingFolder
 self folder: 'folder.st'.
 self should: [output writeFileNamed: 'folder.st'] raise: Error.
 self assert: (fixture / 'folder.st') exists.
! !

!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testDialogInitialExtentRespectsFontSize
 | extent |
 extent := VisualFileOutWindow new initialExtent.
 self assert: extent x >= 820.
 self assert: extent y >= ((Preferences at: #standardListFont) lineSpacing * 24).
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
!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testDecliningOverwritePreservesFileAndOpenDialog
 | window |
 self writeSource: 'export.st' contents: 'original'.
 window := self openWindow: VisualFileDialogsTestExportWindow model: output.
 window saveFile.
 self assert: (fixture // 'export.st') textContents = 'original'.
 self assert: window owner notNil.
 self assert: output class rememberedDirectoryPath isNil.
! !
!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testAcceptingOverwriteWritesAndClosesDialog
 | window |
 self writeSource: 'export.st' contents: 'original'.
 window := self openWindow: VisualFileDialogsTestExportWindow model: output.
 window overwriteAnswer: true.
 window saveFile.
 self assert: (fixture // 'export.st') textContents = 'test contents'.
 self assert: window owner isNil.
! !
!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testCancellingNewFolderDoesNotCreateAnything
 | window |
 window := self openWindow: VisualFileDialogsTestExportWindow model: output.
 window createDirectory.
 self assert: fixture children isEmpty.
 self assert: output directory = fixture.
! !
!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testNewFolderDialogCreatesAndOpensFolder
 | window |
 window := self openWindow: VisualFileDialogsTestExportWindow model: output.
 window folderAnswer: 'UI Folder'.
 window createDirectory.
 self assert: output directory = (fixture / 'UI Folder').
 self assert: output directory exists.
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
!VisualFileDialogsTest methodsFor: 'tests' stamp: 'VFDTests 7/Nov/2026 12:00:00'!
testRecoveryFailureRetainsBackupAndReportsItsPath
 | failing backups |
 self writeSource: 'existing.st' contents: 'original'.
 failing := VisualFileDialogsTestRecoveryFailureModel new.
 failing goHome; navigateTo: fixture; suggestedName: 'existing.st' writer: [:stream | stream nextPutAll: 'replacement'].
 self should: [failing writeFileNamed: 'existing.st'] raise: Error withExceptionDo: [:error |
 backups := fixture files select: [:file | file name endsWith: '.bak'].
 self assert: backups size = 1.
 self assert: (error messageText includesSubString: backups first pathName)].
 self assert: backups first textContents = 'original'.
 self assert: fixture children size = 1.
 self assert: failing class rememberedDirectoryPath isNil.
! !
