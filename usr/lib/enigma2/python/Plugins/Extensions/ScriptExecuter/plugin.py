## ScriptExecuter
## by AliAbdul - newnigma
##
from Components.ActionMap import ActionMap
from Components.MenuList import MenuList
import os
from Plugins.Plugin import PluginDescriptor
from Screens.Console import Console
from Screens.Screen import Screen

############################################

class ScriptExecuter(Screen):
	skin = """
	<screen position="150,100" size="420,400" title="Script Executer" >
		<widget name="list" position="0,0" size="420,400" scrollbarMode="showOnDemand" />
	</screen>"""

	def __init__(self, session, args=None):
		Screen.__init__(self, session)
		self.session = session
		
		try:
			list = os.listdir("/usr/script")
			list = [x[:-3] for x in list if x.endswith('.sh')]
		except:
			list = []
		
		self["list"] = MenuList(list)
		
		self["actions"] = ActionMap(["OkCancelActions"], {"ok": self.run, "cancel": self.close}, -1)

	def run(self):
		script = self["list"].getCurrent()
		if script is not None:
			name = ("/usr/script/%s.sh" % script)
			os.chmod(name, 0755)
			self.session.open(Console, script.replace("_", " "), cmdlist=[name])

############################################

def main(session, **kwargs):
	session.open(ScriptExecuter)

def Plugins(**kwargs):
	return PluginDescriptor(name=_("Script Executer"), description=_("Executes your scripts in /usr/script"), where=PluginDescriptor.WHERE_PLUGINMENU, fnc=main)
