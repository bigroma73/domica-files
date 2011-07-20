from Components.ActionMap import ActionMap
from Components.MenuList import MenuList
import os
from Plugins.Plugin import PluginDescriptor
from Screens.Console import Console
from Screens.Screen import Screen


class EmuStarter(Screen):
	skin = """
        <screen position="center,center" size="640,320" title="%s" >
            <widget name="list" position="20,65"    size="600,255" scrollbarMode="showOnDemand" />
            <ePixmap position="20,10" zPosition="1" size="600,40"  transparent="1" alphatest="on" pixmap="/usr/lib/enigma2/python/Plugins/Extensions/Domica/domica-plugin.png" />
        </screen>""" % _("Activate Softcam")
	def __init__(self, session, args=None):
		Screen.__init__(self, session)
		self.session = session
		
		try:
			list = os.listdir("/usr/emu")
			list = [x[:-3] for x in list if x.endswith('.sh')]
		except:
			list = []
		
		self["list"] = MenuList(list)
		
		self["actions"] = ActionMap(["OkCancelActions"], {"ok": self.run, "cancel": self.close}, -1)

	def run(self):
		script = self["list"].getCurrent()
		if script is not None:
			name = ("/usr/emu/%s.sh" % script)
			os.chmod(name, 0755)
			self.session.open(Console, script.replace("_", " "), cmdlist=[name])

