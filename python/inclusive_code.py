import re
import astroid
import humps
import tokenize
import yaml

from pylint.checkers import BaseChecker
from pylint.interfaces import IAstroidChecker,ITokenChecker
from pylint.utils import get_global_option


def _all_patterns(words):
    return '|'.join(p for w in words
                      for p in (w, w.replace(' ', '_'), humps.camelize(w.replace(' ', '_'))))

class InclusiveCodeChecker(BaseChecker):
    __implements__ = IAstroidChecker

    name = "inclusive code"
    priority = -1
    msgs = {
        "W1564": ("Use of non-inclusive word %r detected. Try %s",
                  "inclusive-code-violation",
                  "See inclusive_code_flagged_terms in your pylint config"),
    }

    options = (
        ('global-config-path', {
            'type': 'string',
        }),
    )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._config = None
    
    def _lazy_load_config(self):
        if self._config:
            return self._config
        with open(self.config.global_config_path) as f:
            self._config = yaml.safe_load(f)
        return self._config

    def _check_name(self, name, node):
        for word, rule in self._lazy_load_config()['flagged_terms'].items():
            pat = _all_patterns([word])
            if not re.search(pat, name, re.RegexFlag.IGNORECASE):
                continue
            allowed_pat = _all_patterns(rule['allowed'])
            if re.search(allowed_pat, name, re.RegexFlag.IGNORECASE):
                continue
            self.add_message('inclusive-code-violation',
                             args=(name, ', '.join(rule['suggestions'])),
                             node=node)
            break

    def visit_classdef(self, node):
        self._check_name(node.name, node)

    def visit_assignname(self, node):
        self._check_name(node.name, node)

    def visit_assignattr(self, node):
        self._check_name(node.attrname, node)

    def visit_functiondef(self, node):
        self._check_name(node.name, node)
        if node.doc:
            self._check_name(node.doc, node)
    
    def visit_const(self, node):
        if isinstance(node.value, str):
            self._check_name(node.value, node)

class InclusiveCommentsChecker(BaseChecker):
    __implements__ = ITokenChecker

    name = "inclusive comments"
    priority = -1
    msgs = {
        "W1565": ("Use of non-inclusive word %r in comments detected. Try %s",
                  "inclusive-comments-violation",
                  "See inclusive_code_flagged_terms in your pylint config"),
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._config = None
    
    def _lazy_load_config(self):
        if self._config:
            return self._config
        with open(get_global_option(self, "global-config-path")) as f:
            self._config = yaml.safe_load(f)
        return self._config

    def _check_name(self, name, line):
        for word, rule in self._lazy_load_config()['flagged_terms'].items():
            pat = _all_patterns([word])
            if not re.search(pat, name, re.RegexFlag.IGNORECASE):
                continue
            allowed_pat = _all_patterns(rule['allowed'])
            if re.search(allowed_pat, name, re.RegexFlag.IGNORECASE):
                continue
            self.add_message('inclusive-comments-violation',
                             args=(name, ', '.join(rule['suggestions'])),
                             line=line)
            break

    def process_tokens(self, tokens):
        comments = (
            info for info in tokens if info.type == tokenize.COMMENT
        )
        for comment in comments:
            for name in comment.string.split(' '):
                self._check_name(name, comment.start[0])


def register(linter):
    linter.register_checker(InclusiveCodeChecker(linter))
    linter.register_checker(InclusiveCommentsChecker(linter))
