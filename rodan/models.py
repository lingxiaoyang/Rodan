from django.db import models
from views import *
from django.utils import *
from projects.models import *

import gamera.core as gam
from gamera.plugins import threshold

class Page(models.Model):
	PIXELTYPE_CHOICES = (
	(0,"RGB"),
	(1,"grey_scale"))

	image_name = models.CharField(max_length=50)
	path_to_image = models.CharField(max_length=200) #full path + file name? or just directory location?
	pixel_type = models.IntegerField(choices=PIXELTYPE_CHOICES)
	width = models.IntegerField()
	height = models.IntegerField()
	size_in_kB = models.IntegerField()

	project = models.ForeignKey(Project)

	def __unicode__(self):
		return "Page %s" % (self.path_to_image + self.image_name)

	def get_num_pixels(self):
		return self.width * self.height

	def get_size_in_mB(self):
		return (size_in_kB / 1024)
		

class Workflow(models.Model):
	wf_name = models.CharField(max_length=50)
	wf_description = models.CharField(max_length=250)

	project = models.ForeignKey(Project)

	def __unicode__(self):
		return "Workflow name: %s" % self.wf_name