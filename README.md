# VisualFileDialogs

Morphic file dialogs for importing and exporting Smalltalk code in CuisUniversity.
The interface follows the active Cuis theme.

This is the first release of the project (v1.0).

## Packages

- **VisualFileDialogs** — File In and File Out dialogs.
- **VisualFileDialogsTests** — 50 SUnit regression tests.

Requires Cuis with Morphic, SUnit and a VM providing `primitiveGetenv`.
Goodies is not required.

## Installation

Close existing dialogs before upgrading. In Cuis File List, select
`VisualFileDialogs.pck.st` and choose **install package**.
Install `VisualFileDialogsTests.pck.st` afterwards to run the tests.

## Usage

- **File Out:** select a category, class, protocol or method in the Browser and
  choose **File Out with Explorer (O)**, or press **Ctrl + Shift + O**.
  Choose a destination, enter a file name and click **Save**.
- **File In:** choose **File In with Explorer** from the World popup, select one or more
  `.st` or `.cs` files and click **File In**. It has no keyboard shortcut.
  Click to mark or unmark files. Hold the left mouse button and drag across rows:
  starting on an unmarked row marks the range; starting on a marked row unmarks it.
  Automatic refresh preserves the selection; navigation clears it. Files load in list order;
  loading stops on the first error, and earlier changes remain applied.
  Use **install package** for `.pck.st` files.
- **New Folder:** create a directory inside the current location from File Out.
- **Navigation:** use Home, Up, the folder tree or double-click a folder.
  Browsing stays within the home directory and hides dot-prefixed folders.

File In and File Out remember their last successful folders independently inside
Smalltalk. Saving the image preserves those values; closing without saving loses
subsequent changes. No folder-state text files are used.

Existing files require overwrite approval. Exports use a temporary file and backup
for recovery on write errors. File In uses standard Cuis loading: earlier chunks
may remain applied if a later chunk fails.

## Tests

After installing both packages, evaluate in a Workspace and inspect the result:

```smalltalk
| suite |
suite := TestSuite new.
VisualFileDialogsTest addToSuiteFromSelectors: suite.
suite run
```

Alternatively select `VisualFileDialogsTest` in the Browser and choose **Run Tests**.
Run the suite serially with the project directory inside your home folder.
Tests group input variants of the same rule and report the failing scenario.
Write, commit and recovery failures are tested independently.

The original 42 tests passed on Linux with CuisUniversity 7.9-8309 and Cuis 7.9-8257.
The multiple-selection update ran 50 tests on a temporary Cuis 7.9-8257 image:
49 passed, including all eight new tests. The overwrite-window test (27) also
fails on the original package in the same headless environment. Interactive
selection still needs validation in a running desktop image.
Tested on Windows: all functionality works correctly.
Native macOS validation is still pending.
The suite uses test doubles for symbolic-link rejection; directory and source-file
links were also checked on Linux. Dangling links are not reliably detected by the
Cuis filesystem API and remain a limitation.
File and folder names share portable validation, including Windows reserved names.
The World menu uses the standard `worldMenuOptions` hook without replacing core methods.

## Multiple-selection implementation

`VisualFileInWindow>>morphicFileListPane` connects `PluggableListMorphOfMany`
to the model. Cuis handles the gesture in `mouseButton1Down:localPosition:`,
`mouseMove:localPosition:` and `mouseButton1Up:localPosition:`. The package
receives each row's requested state through `fileListSelectionAt:put:`.

`VisualFileInModel` groups the selection protocol under `selection`, its helpers
under `selection - private`, automatic refresh under `updating`, and folder
changes under `navigation`. Refresh restores selection by entry rather than
position; import reads selected source files in list order.

## License

[MIT License](LICENSE). Original Cuis copyright notices are retained.
