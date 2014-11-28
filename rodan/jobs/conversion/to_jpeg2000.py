import PIL.Image
import subprocess
import tempfile
import shutil
import os
from django.core.files import File
from rodan.jobs.base import RodanAutomaticTask

PATH_TO_KDU = "/usr/local/bin/kdu_compress"
PATH_TO_VIPS = "/usr/local/bin/vips"


class to_jpeg2000(RodanAutomaticTask):
    name = 'rodan.jobs.conversion.to_jpeg2000'
    author = 'Andrew Hankinson'
    description = "Converts an image to a JPEG2000 image suitable for display in Diva"
    settings = ()
    enabled = True
    categroy = "Conversion"

    input_port_types = ({'name': 'in',
                         'minimum': 1,
                         'maximum': 1,
                         'resource_types': lambda mime: mime.starts_with('image/')})
    output_port_types = ({'name': 'out',
                          'minimum': 1,
                          'maximum': 1,
                          'resource_types': ['image/rgb+jpeg2000']})

    def run_my_task(self, inputs, settings, outputs):
        task_image = inputs['in'][0]['resource_path']
        output_save_path = outputs['out'][0]['resource_path']

        tdir = tempfile.mkdtemp()
        name = os.path.basename(task_image)
        name, ext = os.path.splitext(name)
        tfile = os.path.join(tdir, "{0}.tiff".format(name))

        subprocess.call([PATH_TO_VIPS,
                         "im_copy",
                         task_image,
                         tfile])
        result_file = "{0}.jpx".format(name)
        output_file = os.path.join(tdir, result_file)

        subprocess.call([PATH_TO_KDU,
                         "-i", tfile,
                         "-o", output_file,
                         "-quiet",
                         "Clevels=5",
                         "Cblk={64,64}",
                         "Cprecincts={256,256},{256,256},{128,128}",
                         "Creversible=yes",
                         "Cuse_sop=yes",
                         "Corder=LRCP",
                         "ORGgen_plt=yes",
                         "ORGtparts=R",
                         "-rate", "-,1,0.5,0.25"])

        f = open(output_file, 'rb')
        f.save(os.path.join(output_save_path, output_file), File(f))
        f.close()
        shutil.rmtree(tdir)

        return True

    def test_my_task(self, testcase):
        inputs = {
            'in': [
                {'resource_type': 'image/jpeg',
                 'resource_path': testcase.new_available_path()
                 }
            ]
        }
        PIL.Image.new("RGBA", size=(50, 50), color=(256, 0, 0)).save(inputs['in'][0]['resource_path'], 'JPEG')
        outputs = {
            'out': [
                {'resource_type': 'image/rgb+png',
                 'resource_path': testcase.new_available_path()
                 }
            ]
        }

        self.run_my_task(inputs, {}, outputs)
        result = PIL.Image.open(outputs['out'][0]['resource_path'])
        testcase.assertEqual(result.format, 'JPEG2000')