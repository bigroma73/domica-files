from __init__ import _
from Screens.About import About
from Plugins.Plugin import PluginDescriptor
from Components.ActionMap import ActionMap
from Components.MenuList import MenuList
from Screens.Standby import TryQuitMainloop
from Screens.Screen import Screen
from Screens.MessageBox import MessageBox
from Screens.PluginBrowser import PluginBrowser
from Screens.Console import Console
from Components.Sources.StaticText import StaticText
import os
try:
	from Plugins.Extensions.ScriptExecuter.plugin import ScriptExecuter
except:
	pass

swapfile = "/media/hdd/swapfile"
domica_pluginversion = "Domica image 8.0"
ntpserver = "0.ua.pool.ntp.org"
time_programm = "/usr/bin/ntpdate"
backup_programm = "/usr/bin/build-nfi-image.sh"


session = None

def autostart(reason, **kwargs):
	global session
	if reason == 0 and kwargs.has_key("session"):
		session = kwargs["session"]
		session.open(DomicaBoot)

class DomicaBoot(Screen):
	def __init__(self,session):
		Screen.__init__(self,session)
		self.session = session

class DomicaButton(Screen):
	def __init__(self,session,button):
		Screen.__init__(self,session)
		self.session = session

def main(session,**kwargs):
	try:
		session.open(Domica)
	except:
		print "[DOMICA] Pluginexecution failed"


class DomicaSubMenu(Screen):
	skin = """
	<screen position="center,center" size="640,320" title="Menu Domica Plugin" >
			<widget name="list" position="20,65" size="600,205"  scrollbarMode="showOnDemand" enableWrapAround="1" />
			<ePixmap            position="20,10" size="600,40" zPosition="1" transparent="1" alphatest="on" pixmap="/usr/lib/enigma2/python/Plugins/Extensions/Domica/domica-plugin.png" />
			<ePixmap pixmap="hd-line_tvpro/buttons/red.png"    position="40,280" size="16,16"  alphatest="blend" />
			<ePixmap pixmap="hd-line_tvpro/buttons/green.png"  position="190,280" size="16,16"  alphatest="blend" />
			<ePixmap pixmap="hd-line_tvpro/buttons/yellow.png" position="340,280" size="16,16"  alphatest="blend" />
			<ePixmap pixmap="hd-line_tvpro/buttons/blue.png"   position="490,280" size="16,16"  alphatest="blend" />
			<widget source="key_red" render="Label" position="65,280" size="120,24" font="Regular;17" valign="top" halign="left" foregroundColor="blue_tux" backgroundColor="blue_tux4" transparent="1" />
			<widget source="key_green"    render="Label" position="215,280" size="120,22" font="Regular;17" valign="top" halign="left" foregroundColor="blue_tux" backgroundColor="blue_tux4" transparent="1" />
			<widget source="key_yellow"   render="Label" position="365,280" size="120,22" font="Regular;17" valign="top" halign="left" foregroundColor="blue_tux" backgroundColor="blue_tux4" transparent="1" />
			<widget source="key_blue"     render="Label" position="515,280" size="120,22" font="Regular;1" valign="top" halign="left" foregroundColor="blue_tux" backgroundColor="blue_tux4" transparent="1" />
	</screen>"""
	def __init__(self,session,sub_m):
		self.sub_m=sub_m
		self.skin=DomicaSubMenu.skin
		self.consoleresults = {}
		self.session = session
		Screen.__init__(self, session)
		self["key_red"] =  StaticText(" ")
		self["key_green"] =  StaticText(" ")
		self["key_yellow"] =  StaticText(" ")
		self["key_blue"] =  StaticText(" ")

		if sub_m is "Emu":
			emumenu = []
			emumenu.append((_("Start softcam"),"0"))
			emumenu.append((_("Stop softcam"),"1"))
			emumenu.append((_("Remove active softcam"),"2"))
			emumenu.append(("mgcamd-1.35a","3"))
			emumenu.append(("cccam-2.2.1","4"))
			try:
				emus = os.listdir("/usr/emu")
				i=5
				for emu in emus:
					if emu.endswith('.sh') and emu[:-3] != "mgcamd-1.35a" and emu[:-3] != "cccam-2.2.1":
						emumenu.append((emu[:-3],"%s" %i))
						i+=1
			except:
				pass
#			emumenu.append((_("Softcam current info"),"3"))
			self["key_red"].text = _("Restart")
			self["key_green"].text = _("Start")
			self["key_yellow"].text = _("Stop")
			self["list"] = MenuList(emumenu)
			self["actions"] = ActionMap(["OkCancelActions","ColorActions"],
								{"ok": self.EmuMenu, 
								"cancel": self.close, 
								"red": self.emuRestart, 
								"green": self.emuStart,
								"yellow": self.emuStop}, -1)
		elif sub_m is "Cfg":
			self.CfgMenu()
		elif sub_m is "Ipk":
			ipkmenu = []
			files=os.listdir('/tmp')
			i=0
			for file in sorted(files):
				if  file.endswith('.ipk'):
					ipkmenu.append((file[:-4],"%s" %i))
					i+=1
			if ipkmenu == []:
				ipkmenu.append((_("No packages"),"0"))
				self["key_red"].text =  _("Online update")
				self["list"] = MenuList(ipkmenu)
				self["actions"] = ActionMap(["OkCancelActions","ColorActions"], {"ok": self.close, "cancel": self.close, "red": self.updIpk}, -1)
			else:
				self["key_red"].text = _("Online update")
				self["key_green"].text = _("Install all")
				self["key_yellow"].text = _("Remove")
				self["key_blue"].text = _("Remove All")
				self["list"] = MenuList(ipkmenu)
				self["actions"] = ActionMap(["OkCancelActions","ColorActions"], 
									{"ok": self.instOne, 
									"cancel": self.close,
									"red": self.updIpk,
									"green": self.instAll,
									"yellow": self.rmOne,
									"blue": self.rmAll
									}, -1)
		else:
			self.session.open(MessageBox,_("Unknown choice"), MessageBox.TYPE_INFO)

	def updIpk(self):
		name = ("ipkg update && ipkg upgrade")
		self.session.open(Console,title = _("Console"),cmdlist = [name], finishedCallback = self.close,closeOnSuccess = True)


	def instOne(self):
		name = ("ipkg install /tmp/%s.ipk" % self["list"].getCurrent()[0])
		self.session.open(Console,title = _("Console"),cmdlist = [name], finishedCallback = self.close,closeOnSuccess = True)

	def instAll(self):
		name = ("ipkg install *.ipk")
		self.session.open(Console,title = _("Console"),cmdlist = [name], finishedCallback = self.close,closeOnSuccess = True)

	def rmOne(self):
		os.system("rm /tmp/%s.ipk" % self["list"].getCurrent()[0])
		self.session.openWithCallback(self.close,MessageBox,(_("Package removed")), MessageBox.TYPE_INFO,timeout=3)

	def rmAll(self):
		os.system("rm /tmp/*.ipk")
		self.session.openWithCallback(self.close,MessageBox,(_("Packages removed")), MessageBox.TYPE_INFO,timeout=3)

	def isSwapPossible(self):
		f = open("/proc/mounts", "r")
		for line in f:
			fields= line.rstrip('\n').split()
			if fields[1] == '/media/hdd':
				if fields[2] == 'ext2' or fields[2] == 'ext3' or fields[2] == 'fat32':
					return 1
				else:
					return 0
		return 0

	def isBackupPossible(self):
		p = os.popen('df')
		for line in p:
			fields = line.lstrip().rstrip('\n').split()
			if line[0] == " ":
				if fields[4] == "/media/hdd":
					if int(fields[2][:-6]) > 50:
						return 1
					else:
						return 0
			else:
				try:
					if fields[5] == "/media/hdd":
						if int(fields[3][:-6]) > 50:
							return 1
						else:
							return 0
				except:
					pass
		return 0

	def CfgMenu(self):
		cfgmenu = []
		if os.path.exists(time_programm):
			cfgmenu.append((_("Set time from internet"),"0"))
		cfgmenu.append((_("Setup neitrino keymap"),"1"))
		cfgmenu.append((_("Setup enigma2 keymap"),"2"))
		if os.path.exists(backup_programm) and self.isBackupPossible()==1:
			cfgmenu.append((_("Backup full image to HDD"),"3"))
		if self.isSwapPossible():
			if os.path.exists(swapfile):
				if self.isSwapRun():
					cfgmenu.append((_("Swap off"),"5"))
				else:
					cfgmenu.append((_("Swap on"),"4"))
					cfgmenu.append((_("Remove swap"),"7"))
			else:
				cfgmenu.append((_("Make swap"),"6"))
		if	os.path.exists('/etc/startup.mp3'):
			cfgmenu.append((_("Remove startup sound"),"8"))

		self["list"] = MenuList(cfgmenu)
		self["actions"] = ActionMap(["OkCancelActions"], {"ok": self.CfgMenuDo, "cancel": self.close}, -1)

	def isSwapRun(self):
		try:
			f=open('/proc/swaps','r')
		except:
			return 0
		i = 0
		for line in f:
			i+=1
		if i == 0:
			return 0
		else:
			return 1

	def emuStart(self):
		os.system("/etc/rcS.d/S50emu start")
		self.session.open(MessageBox,(_("Emu started")), MessageBox.TYPE_INFO,timeout=4)

	def emuStop(self):
		os.system("/etc/rcS.d/S50emu stop")
		self.session.open(MessageBox,(_("Emu stoped")), MessageBox.TYPE_INFO,timeout=2)

	def emuRestart(self):
		os.system("/etc/rcS.d/S50emu restart")
		self.session.open(MessageBox,_("Emu restarting"), MessageBox.TYPE_INFO, timeout=4)

	def EmuMenu(self):
		m_choice = self["list"].getCurrent()
		if m_choice[1] is "0":
			os.system("/etc/rcS.d/S50emu start")
			self.session.openWithCallback(self.close,MessageBox,(_("Emu started")), MessageBox.TYPE_INFO,timeout=3)
		elif m_choice[1] is "1":
			os.system("/etc/rcS.d/S50emu stop")
			self.session.openWithCallback(self.close,MessageBox,(_("Emu stoped")), MessageBox.TYPE_INFO,timeout=3)
		elif m_choice[1] is "2":
			os.system("/etc/rcS.d/S50emu stop")
			f = open("/etc/active_emu.list","w")
			f.write("No emu")
			f.close()
			self.session.openWithCallback(self.close,MessageBox,(_("Emu disabled")), MessageBox.TYPE_INFO,timeout=3)
		elif m_choice[1] is "3":
			os.system("/etc/rcS.d/S50emu stop")
			if not os.path.exists("/usr/emu/mgcamd-1.35a.sh"):
				name = ("ipkg update && ipkg install softcam-mgcamd-1.35a")
				self.session.open(Console,title = _("Console"),cmdlist = [name],closeOnSuccess = True)
			f = open("/etc/active_emu.list","w")
			f.write(m_choice[0])
			f.close()
			os.system("/etc/rcS.d/S50emu start")
			self.close()
		elif m_choice[1] is "4":
			os.system("/etc/rcS.d/S50emu stop")
			if not os.path.exists("/usr/emu/cccam-2.2.1.sh"):
				name = ("ipkg update && ipkg install softcam-cccam-2.2.1")
				self.session.open(Console,title = _("Console"),cmdlist = [name],closeOnSuccess = True)
			f = open("/etc/active_emu.list","w")
			f.write(m_choice[0])
			f.close()
			os.system("/etc/rcS.d/S50emu start")
			self.close()
		else:
			os.system("/etc/rcS.d/S50emu stop")
			f = open("/etc/active_emu.list","w")
			f.write(m_choice[0])
			f.close()
			os.system("/etc/rcS.d/S50emu start")
			self.close()


	def CfgMenuDo(self):
		m_choice = self["list"].getCurrent()[1]

		if	m_choice is "0":
			tmpstr=time_programm + " " + ntpserver
			if os.system(tmpstr) == 0:
				self.session.openWithCallback(self.close,MessageBox,(_("Time sync")), MessageBox.TYPE_INFO,timeout=3)
			else:
				self.session.openWithCallback(self.close,MessageBox,(_("Error time sync")), MessageBox.TYPE_INFO,timeout=3)
		elif m_choice is "1":
			os.system("cp -f /usr/share/enigma2/keymap_neutrino.xml /usr/share/enigma2/keymap.xml")
			os.system("cp -f /usr/share/enigma2/keymap-2ib-n.xml /usr/lib/enigma2/python/Plugins/Extensions/2IB/keymap.xml")
			restartbox = self.session.openWithCallback(self.restartGUI,MessageBox,_("GUI needs a restart to apply a new skin\nDo you want to Restart the GUI now?"),MessageBox.TYPE_YESNO)
			restartbox.setTitle(_("Restart GUI now?"))
		elif m_choice is "2":
			os.system("cp -f /usr/share/enigma2/keymap_new.xml /usr/share/enigma2/keymap.xml")
			os.system("cp -f /usr/share/enigma2/keymap-2ib.xml /usr/lib/enigma2/python/Plugins/Extensions/2IB/keymap.xml")
			restartbox = self.session.openWithCallback(self.restartGUI,MessageBox,_("GUI needs a restart to apply a new skin\nDo you want to Restart the GUI now?"),MessageBox.TYPE_YESNO)
			restartbox.setTitle(_("Restart GUI now?"))
		elif m_choice is "3":
			tmpstr=backup_programm + " /media/hdd"
			self.session.open(Console,title = _("Backup to HDD"),cmdlist = [tmpstr], finishedCallback = self.close,closeOnSuccess = True)
		elif m_choice is "4":
			tmpstr="swapon " + swapfile
			os.system(tmpstr)
			self.session.openWithCallback(self.close,MessageBox,(_("Swap file started")), MessageBox.TYPE_INFO,timeout=3)
		elif m_choice is "5":
			tmpstr="swapoff " + swapfile
			os.system(tmpstr)
			self.session.openWithCallback(self.close,MessageBox,(_("Swap file stoped")), MessageBox.TYPE_INFO,timeout=3)
		elif m_choice is "6":
			tmpstr="dd if=/dev/zero of=" + swapfile + " bs=1024 count=8192"
			os.system(tmpstr)
			tmpstr = "mkswap " + swapfile
			os.system(tmpstr)
			self.session.openWithCallback(self.close,MessageBox,(_("Swap file created")), MessageBox.TYPE_INFO,timeout=3)
		elif m_choice is "7":
			tmpstr="rm " + swapfile
			os.system(tmpstr)
			self.session.openWithCallback(self.close,MessageBox,(_("Swap file removed")), MessageBox.TYPE_INFO,timeout=3)
		elif m_choice is "8":
			os.system("rm /etc/startup.mp3")
			self.session.openWithCallback(self.close,MessageBox,(_("Startup sound removed")), MessageBox.TYPE_INFO,timeout=3)
		else:
			self.session.open(MessageBox,(_("Unknown choice")), MessageBox.TYPE_INFO)

	def restartGUI(self, answer):
		if answer is True:
			self.session.open(TryQuitMainloop, 3)

class Domica(Screen):
	skin = """
		<screen position="center,center" size="640,320" title="%s" >
			<widget name="menu" position="20,65"	size="600,255" />
			<ePixmap position="20,10" zPosition="1" size="600,40"  transparent="1" alphatest="on" pixmap="/usr/lib/enigma2/python/Plugins/Extensions/Domica/domica-plugin.png" />
			<widget source="session.CurrentService" render="EmuLabel" zPosition="5" position="370,69" size="250,20" font="Regular;18" foregroundColor="#6a7a8a" halign="right" transparent="1"/>
		</screen>""" % _("Menu Domica Plugin")

	def __init__(self, session, args = 0):
		self.skin = Domica.skin
		self.session = session
		Screen.__init__(self, session)
		self.menu = args

		mainmenu = []
		mainmenu.append((_("Restart cam"),"0"))
		mainmenu.append((_("Cam menu"),"4"))
		mainmenu.append((_("Ipk Menu"),"7"))
		mainmenu.append((_("Configure"),"3"))
		mainmenu.append((_("Plugins"),"2"))
		try:
			from Plugins.Extensions.ScriptExecuter.plugin import ScriptExecuter
			mainmenu.append((_("Execute user script from /usr/script"),"6"))
		except:
			pass
		mainmenu.append((_("about %s") % domica_pluginversion , "8"))

		self["menu"] = MenuList(mainmenu)
		self["actions"] = ActionMap(["WizardActions", "DirectionActions"],{"ok": self.DomicaMainMenu,"back": self.close,}, -2)


	def DomicaMainMenu(self):
		m_choice = self["menu"].l.getCurrentSelection()[1]

		if m_choice is "0":
			os.system("/etc/rcS.d/S50emu restart")
			self.session.openWithCallback(self.close,MessageBox,_("Emu restarting"), MessageBox.TYPE_INFO, timeout=4)
		elif m_choice is "2":
			self.session.open(PluginBrowser)
		elif m_choice is "3":
			self.session.open(DomicaSubMenu,"Cfg")
		elif m_choice is "4":
			self.session.open(DomicaSubMenu,"Emu")
			self.close()
		elif  m_choice is "6":
			self.session.open(ScriptExecuter)
		elif m_choice is "7":
			self.session.open(DomicaSubMenu,"Ipk")
		elif m_choice is "8":
			self.session.open(About)
		else:
			self.session.open(MessageBox,("Menu Domica Plugin %s\nby Domica Forum www.domica.biz !") % m_choice, MessageBox.TYPE_INFO)

def Plugins(**kwargs):
		try:
			return [PluginDescriptor(name="Menu Domica", description="Menu Domica Plugin", where = PluginDescriptor.WHERE_PLUGINMENU, icon="domica.png", fnc=main),
					PluginDescriptor(name="Menu Domica", description="Menu Domica Plugin", where = PluginDescriptor.WHERE_EXTENSIONSMENU, icon="domica.png", fnc=main)]
		except:
			return [PluginDescriptor(where = [PluginDescriptor.WHERE_SESSIONSTART, PluginDescriptor.WHERE_AUTOSTART], fnc = autostart),PluginDescriptor(name="Domica",
					description="Menu Domica Plugin", where = PluginDescriptor.WHERE_PLUGINMENU, icon="domica.png", fnc=main)]
