import inclusive_code
import astroid
from pylint.checkers import variables
from pylint.testutils import CheckerTestCase, Message, _tokenize_str

class TestInclusiveCodeChecker(CheckerTestCase):
    CHECKER_CLASS = inclusive_code.InclusiveCodeChecker
    CONFIG = {"global_config_path": "../inclusive_code_flagged_terms.yml"}

    def test_finds_violations_in_class_names(self):
        node = astroid.extract_node("class MasterClass: pass")
        msg = Message(msg_id="inclusive-code-violation", node=node, args=('MasterClass', 'leader, primary, parent'))
        with self.assertAddsMessages(msg):
            self.walk(node)

    def test_finds_violations_with_underscore_in_class_names(self):
        node = astroid.extract_node("class _MasterClass: pass")
        msg = Message(msg_id="inclusive-code-violation", node=node, args=('_MasterClass', 'leader, primary, parent'))
        with self.assertAddsMessages(msg):
            self.walk(node)

    def test_no_violation_for_allow_in_class_names(self):
        node = astroid.extract_node("class MasterBill: pass")
        msg = Message(msg_id="inclusive-code-violation", node=node, args=('MasterClass', 'leader, primary, parent'))
        with self.assertNoMessages():
            self.walk(node)

    def test_finds_violations_in_functions(self):
        node = astroid.extract_node("def master_function(): pass")
        msg = Message(msg_id="inclusive-code-violation", node=node, args=('master_function', 'leader, primary, parent'))
        with self.assertAddsMessages(msg):
            self.walk(node)

    def test_finds_violations_in_assignment(self):
        node = astroid.extract_node("master_variable = True")
        msg = Message(msg_id="inclusive-code-violation", node=node.targets[0], args=('master_variable', 'leader, primary, parent'))
        with self.assertAddsMessages(msg):
            self.walk(node)

    def test_finds_violations_in_assignment_with_underscore(self):
        node = astroid.extract_node("_master_variable = True")
        msg = Message(msg_id="inclusive-code-violation", node=node.targets[0], args=('_master_variable', 'leader, primary, parent'))
        with self.assertAddsMessages(msg):
            self.walk(node)

    def test_finds_violations_in_self_assignment(self):
        node = astroid.extract_node("self.master_variable = True")
        msg = Message(msg_id="inclusive-code-violation", node=node.targets[0], args=('master_variable', 'leader, primary, parent'))
        with self.assertAddsMessages(msg):
            self.walk(node)

    def test_finds_violations_in_const(self):
        node = astroid.extract_node("_ = 'master string'")
        msg = Message(msg_id="inclusive-code-violation", node=node.value, args=('master string', 'leader, primary, parent'))
        with self.assertAddsMessages(msg):
            self.walk(node)

class TestInclusiveCommentsChecker(CheckerTestCase):
    CHECKER_CLASS = inclusive_code.InclusiveCommentsChecker
    CONFIG = {"global_config_path": "../inclusive_code_flagged_terms.yml"}

    def test_finds_violations_in_comments(self):
        with self.assertAddsMessages(
            Message(
                "inclusive-comments-violation",
                line=1,
                args=('master', 'leader, primary, parent')
            )
        ):
            self.checker.process_tokens(_tokenize_str("# this is a master comment"))