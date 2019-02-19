"""
  ()_()      .-.        _               \\\  ///
  (O o)    c(O_O)c     /||_       /)    ((O)(O))
   |^_\   ,'.---.`,     /o_)    (o)(O)   | \ ||
   |(_)) / /|_|_|\ \   / |(\     //\\    ||\\||
   |  /  | \_____/ |   | | ))   |(__)|   || \ |
   )|\\  '. `---' .`   | |//    /,-. |   ||  ||
  (/  \)   `-...-'     \__/    -'   ''  (_/  \_)
"""


# This will make sure the app is always imported when
# Django starts so that shared_task will use this app.
from .celery import app as celery_app

# Module versioning follows PEP 396
# Get version: import rodan; rodan.__version__
# Version numbers also appear in the API.
__title__ = "Rodan"
__version__ = "1.1.5"
__copyright__ = "Copyright 2011-2018 Distributed Digital Music Archives & Libraries Lab"
