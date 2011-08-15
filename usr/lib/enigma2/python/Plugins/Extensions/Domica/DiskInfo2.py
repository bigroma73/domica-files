import os
from Screens.Screen import Screen
from Components.ActionMap import ActionMap
from Components.Sources.StaticText import StaticText



class DiskInfo2(Screen):
	hddType = 0 # 0 not present, 1 SATA, 2 USB, 3 Network
	suffix = 'GB'
	div_s = 1048576.0
	skin = """
	<screen position="center,190" size="440,380" title="DiskInfo2">
			<ePixmap position="305,10" zPosition="2" size="124,25" pixmap="/usr/lib/enigma2/python/Plugins/Extensions/Domica/diskinfo2.png" />
			<eLabel position="15,200" size="410,3" />
			<widget source="HDD_Model" render="Label" position="10,45" size="420,25" font="Regular;20" />
			<widget source="HDD_FS" render="Label" position="10,70" size="420,25" font="Regular;20" />
			<widget source="HDD_Size" render="Label" position="10,95" size="420,25" font="Regular;20" />
			<widget source="HDD_Used" render="Label" position="10,120" size="420,25" font="Regular;20" />
			<widget source="HDD_Free" render="Label" position="10,146" size="420,25" font="Regular;20" />
			<widget source="HDD_Usage" render="Label" position="10,170" size="420,25" font="Regular;20" />
			<widget source="USB_Model" render="Label" position="10,205" size="420,25" font="Regular;20" />
			<widget source="USB_FS" render="Label" position="10,230" size="420,25" font="Regular;20" />
			<widget source="USB_Size" render="Label" position="10,255" size="420,25" font="Regular;20" />
			<widget source="USB_Used" render="Label" position="10,280" size="420,25" font="Regular;20" />
			<widget source="USB_Free" render="Label" position="10,305" size="420,25" font="Regular;20" />
			<widget source="USB_Usage" render="Label" position="10,330" size="420,25" font="Regular;20" />
	</screen>"""

	def __init__(self, session):
		Screen.__init__(self, session)

		self["HDD_Model"] = StaticText("None")
		self["HDD_FS"] = StaticText(" ")
		self["HDD_Size"] = StaticText(" ")
		self["HDD_Used"] = StaticText(" ")
		self["HDD_Free"] = StaticText(" ")
		self["HDD_Usage"] = StaticText(" ")
		self["USB_Model"] = StaticText("None")
		self["USB_FS"] = StaticText(" ")
		self["USB_Size"] = StaticText(" ")
		self["USB_Used"] = StaticText(" ")
		self["USB_Free"] = StaticText(" ")
		self["USB_Usage"] = StaticText(" ")
		
		
		f = open('/proc/mounts')
		for line in f:
			fields= line.rstrip('\n').split()
			if fields[1] == '/media/hdd':
				self["HDD_FS"] = StaticText(fields[2])
				if fields[2] == 'cifs' or fields[2] == 'nfs':
					self["HDD_Model"] = StaticText(_("Network Share"))
					self.hddType = 3
				else:
					self["HDD_Model"] = StaticText(self.disk_name('/media/hdd'))
				p = os.popen('df')
				for line in p:
					fields1 = line.lstrip().rstrip('\n').split()
					if line[0] == " ":
						if fields1[4] == '/media/hdd':
							tmp_a = len(fields1[0])
							if tmp_a > 9:
								self.div_s=1073741824.0
								self.suffix='TB'
							elif tmp_a < 4:
								self.div_s=1024.0
								self.suffix='MB'
							else:
								self.suffix = _('GB')
								self.div_s = 1048576.0
 							self["HDD_Size"] = StaticText(("%5.1f" % (int(fields1[0])/self.div_s)) + self.suffix)
							self["HDD_Used"] = StaticText(("%5.1f" % (int(fields1[1])/self.div_s)) + self.suffix)
							self["HDD_Free"] = StaticText(("%5.1f" % (int(fields1[2])/self.div_s)) + self.suffix)
							self["HDD_Usage"] = StaticText(fields1[3])
					else:
						try:
							if fields1[5] == '/media/hdd':
								tmp_a = len(fields1[1])
								if tmp_a > 9:
									self.div_s=1073741824.0
									self.suffix='TB'
								elif tmp_a < 4:
									self.div_s=1024.0
									self.suffix='MB'
								else:
									self.suffix = _('GB')
									self.div_s = 1048576.0
								self["HDD_Size"] = StaticText(("%5.1f" % (int(fields1[1])/self.div_s)) + self.suffix)
								self["HDD_Used"] = StaticText(("%5.1f" % (int(fields1[2])/self.div_s)) + self.suffix)
								self["HDD_Free"] = StaticText(("%5.1f" % (int(fields1[3])/self.div_s)) + self.suffix)
								self["HDD_Usage"] = StaticText(fields1[4])
						except:
							pass
			elif fields[1] == '/media/usb':
				self["USB_FS"] = StaticText(fields[2])
				self["USB_Model"] = StaticText(self.disk_name('/media/usb'))
				p = os.popen('df')
				for line in p:
					fields1 = line.lstrip().rstrip('\n').split()
					try:
						if fields1[5] == '/media/usb':
							tmp_a = len(fields1[1])
							if tmp_a > 9:
								self.div_s=1073741824.0
								self.suffix='TB'
							elif tmp_a < 4:
								self.div_s=1024.0
								self.suffix='MB'
							else:
								self.suffix = _('GB')
								self.div_s = 1048576.0
							self["USB_Size"] = StaticText(("%5.1f" % (int(fields1[1])/self.div_s)) + self.suffix)
							self["USB_Used"] = StaticText(("%5.1f" % (int(fields1[2])/self.div_s)) + self.suffix)
							self["USB_Free"] = StaticText(("%5.1f" % (int(fields1[1])/self.div_s)) + self.suffix)
							self["USB_Usage"] = StaticText(fields1[4])
					except:
						pass
			else:
				pass
				

		self["actions"] = ActionMap(["SetupActions", "ColorActions"], 
			{
				"cancel": self.close,
				"ok": self.close
			})

	def disk_name(self, mount_point):
		for root,dirs,files in os.walk('/sys/class/scsi_disk/'):
			break
		dirs.sort()
		if mount_point == '/media/hdd':
			dev_str = '/sys/bus/scsi/devices/'+dirs[0]
			if dirs[0][0] == 0:
				self.hddType = 1
			else:
				self.hddType = 2
		elif mount_point == '/media/usb':
			dev_str = '/sys/bus/scsi/devices/'+dirs[1]
		else:
			return "Unknown device"
		f=open(dev_str + '/vendor')
		tempstr = f.readline().rstrip('\n').rstrip()
		tempstr += ' '
		f=open(dev_str + '/model')
		tempstr += f.readline().rstrip('\n').rstrip()
		return tempstr
