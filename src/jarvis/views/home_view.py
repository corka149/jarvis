from flask import Blueprint

from jarvis.infrastructure import response
from jarvis.viewmodels.viewmodelbase import ViewModelBase

blue_print = Blueprint('home', __name__, template_folder='templates')


@blue_print.route('/')
@blue_print.route('/index.html')
@response(template_file='home/index.html')
def index():
    vm = ViewModelBase()
    return vm.to_dict()
