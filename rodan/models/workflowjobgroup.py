from django.db import models
from uuidfield import UUIDField


class WorkflowJobGroup(models.Model):
    """
    A `WorkflowJobGroup` is a container representing the grouping of `WorkflowJob`s.

    **Fields**

    - `uuid`
    - `name`
    - `description`
    - `origin` -- a nullable reference to the `Workflow` indicating where it comes
      from.

    - `created`
    - `updated`
    """
    uuid = UUIDField(primary_key=True, auto=True)
    name = models.CharField(max_length=100, db_index=True)
    description = models.TextField(blank=True, null=True)
    origin = models.ForeignKey("rodan.Workflow", related_name="workflow_job_groups", blank=True, null=True, on_delete=models.SET_NULL, db_index=True)

    created = models.DateTimeField(auto_now_add=True, db_index=True)
    updated = models.DateTimeField(auto_now=True, db_index=True)

    def __unicode__(self):
        return u"<WorkflowJobGroup {0}>".format(str(self.uuid))

    class Meta:
        app_label = 'rodan'
