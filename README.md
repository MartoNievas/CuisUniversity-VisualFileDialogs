# VisualFileDialogs

Morphic file dialogs for importing and exporting Smalltalk code in CuisUniversity.
The interface follows the active Cuis theme.

This is the first release of the project (v1.0).

## Packages

- **VisualFileDialogs** — File In and File Out dialogs.
- **VisualFileDialogsTests** — 42 SUnit regression tests.

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
- **File In:** choose **File In with Explorer** from the World popup, select a
  `.st` or `.cs` file and click **File In**. It has no keyboard shortcut.
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

All 42 tests passed on Linux with CuisUniversity 7.9-8309 and Cuis 7.9-8257.
Native macOS and Windows validation is still pending.
The suite uses test doubles for symbolic-link rejection; directory and source-file
links were also checked on Linux. Dangling links are not reliably detected by the
Cuis filesystem API and remain a limitation.
File and folder names share portable validation, including Windows reserved names.
The World menu uses the standard `worldMenuOptions` hook without replacing core methods.

## License

[MIT License](LICENSE). Original Cuis copyright notices are retained.
