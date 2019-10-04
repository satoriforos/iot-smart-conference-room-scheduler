from pip.req import parse_requirements

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

install_reqs = parse_requirements(<requirements_path>)
reqs = [str(ir.req) for ir in install_reqs]

config = {
    'description': 'Room Cleaner',
    'author': 'Satori Foros',
    'url': 'https://www.google.com',
    'download_url': 'https://www.google.com',
    'author_email': 'email@example.com',
    'version': '0.1',
    'install_requires': reqs,
    'packages': ['roomcleaner'],
    'scripts': [],
    'name': 'roomcleaner'
}

setup(**config)
