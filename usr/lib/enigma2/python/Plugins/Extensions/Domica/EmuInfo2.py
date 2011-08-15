import os
from Screens.Screen import Screen
from Components.ActionMap import ActionMap
from Components.Sources.StaticText import StaticText
from Components.MenuList import MenuList
from enigma import iServiceInformation, iPlayableService

class EmuInfo2(Screen):
	skin="""
	<screen position="center,120" size="920,515" title="EmuInfo2" >
		<ePixmap position="786,10" zPosition="2" size="124,25" pixmap="/usr/lib/enigma2/python/Plugins/Extensions/Domica/emuinfo2.png" />
		<widget source="Emu" render="Label" position="10,10" size="200,25" font="Regular;20" zPosition="1" />
		<eLabel position="15,40" size="890,3" zPosition="2" />
		<widget source="status" render="Label" position="230,10" size="200,25" font="Regular;20" zPosition="1" />
		<widget name="menu" position="10,50" size="900,455" scrollbarMode="showOnDemand" enableWrapAround="1" zPosition="1" />
	</screen>"""

	def __init__(self, session):
		self.session = session
		Screen.__init__(self, session)

		self.routes=[]
		self["Emu"] = StaticText("No Emu")
		self["status"] = StaticText(" ")
		self["CAID"] = StaticText(" ")
		self["Pid"] = StaticText(" ")
		self["EcmTime"] = StaticText(" ")
		self["Provider"] = StaticText(" ")
		self["Crypt"] = StaticText(" ")
		self["Recon"] = StaticText(" ")

		mainmenu = []

		try:
			f = open("/etc/active_emu.list")
			lines = f.readlines()
			if not lines[0].lower().find('mgcamd'):
				self["Emu"] = StaticText(lines[0].rstrip('\n'))
				if os.path.exists("/tmp/mgcamd.pid"):
					self["status"] = StaticText("Running")
					ecm_file = open("/tmp/ecm.info")
					lines = ecm_file.readlines()
					if len(lines) > 0:
						for line in lines:
							x = line.lower().find("msec")
							if x != -1:
								self["EcmTime"] = StaticText(line[0:x+4])
							else:
								item = line.split(":", 1)
								if len(item) > 1:
									if item[0] == "Provider":
										item[0] = "prov"#wicard
									if item[0] == "prov":
										self["Provider"] = StaticText(item[1].strip()[:6])
								else:
									x = line.lower().find("caid")
									if x != -1:
										y = line.find(",")
										if y != -1:
											self["CAID"] = StaticText(line[x+5:y])
									x = line.lower().find("pid")
									if x != -1:
										y = line.find(" =")
										if y != -1:
											self["Pid"] = StaticText(line[x+4:y])
					else:
						self["Crypt"] = StaticText("FTA")

					mgshare_file = open("/tmp/mgshare.info")
					lines = mgshare_file.readlines()
					mgstat_file = open("/tmp/mgstat.info")
					lines1 = mgstat_file.readlines()
					if len(lines) > 0:
						tmp_t = {}
						i = 0
						for line in lines:
							item = line.split(":")
							item1 = item[0].split(" ")
							tmp_t["no"] = "%d" %i
							tmp_t["protocol"] = item1[0]
							tmp_t["caid"] = item1[2]
							tmp_t["login"] = item[1]
							tmp_t["server"] = item[2]
							tmp_t["port"] = item[3]
							item1 = item[4].split(" ")
							tmp_t["status"] = item1[3].rstrip('\n')
#							mainmenu.append((("%s %s %s %s %s" %(tmp_t["status"],tmp_t["server"],tmp_t["port"],tmp_t["caid"],tmp_t["no"])),tmp_t["no"]))
#							for line1 in lines1[5:-4]:
#								if not line1.find(tmp_t["port"]):
#									self["Pid"] = StaticText(tmp_t["port"])
							tmp_strings = lines1[5:-4][i].strip('\n').split('\t')
#									self["status"] = StaticText(tmp_string[1])
							tmp_t["recon"] = tmp_strings[1]
							tmp_t["emm_out"] = tmp_strings[2]
							tmp_t["ecm_out"] = tmp_strings[3]
							tmp_t["cw_in"] = tmp_strings[4]
							tmp_t["avg_time"] = tmp_strings[5]
							mainmenu.append((("%s %s %s %s %4d %4d %6d %6d %4d" %(tmp_t["status"],tmp_t["server"],tmp_t["port"],tmp_t["caid"],int(tmp_t["recon"]),int(tmp_t["emm_out"]),int(tmp_t["ecm_out"]),int(tmp_t["cw_in"]),int(tmp_t["avg_time"]))),tmp_t["no"]))
							if i == 1:
								self["Recon"] = StaticText("%s" % tmp_t["avg_time"])
#									pass
							self.routes.append(tmp_t)
							i+=1
#					self["Recon"] = StaticText(self.routes[0]["avg_time"])
				else:
					self["status"] = StaticText("Not running")
		except:
			pass

		self["menu"] = MenuList(mainmenu)
		self["actions"] = ActionMap(["OkCancelActions"],{"ok": self.close,"cancel": self.close,}, -2)

