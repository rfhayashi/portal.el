# portal.el

An Emacs package that integrates Elisp with Clojure [Portal](https://github.com/djblue/portal). Elisp data is converted to Clojure data using [parseedn](https://github.com/clojure-emacs/parseedn/tree/main). Data types not supported by parseedn can be converted to a supported type using the `portal-datafy` generic function (see how in usage).

## Project Status

This is still quite experimental. If you've found this useful and had any issue or have ideas on how to make it better, I'd love to get feedback (just open an issue).

## Installation

`portal.el` requires a recent version of [babashka](https://github.com/babashka/babashka) installed.

### Regular emacs

Clone this repo to a folder and add this to your emacs config:

```emacs-lisp
(add-to-list 'load-path "path-to-portal-el-repo")

(require 'portal)
```

### Using straight.el

```emacs-lisp
(straight-use-package
  '(portal :host github :repo "rfhayashi/portal.el"))

(require 'portal)
```

## Usage

## Limitations

At the moment is only possible to send data from emacs to portal and not the other way around (i.e. it is not possible to "deref" the value that is currently selected in portal).
