from win32com.client import DispatchEx
import os

from ..tool_abc import toolabc as abc
from ..token_draw import TokenDraw
from ..token_make import TokenMake
from ...model_obj.dimensions import *

__all__ = []
__all__ += ["JmagDesigner"]


class JmagDesigner(abc.ToolBase, abc.DrawerBase, abc.MakerExtrudeBase, abc.MakerRevolveBase):
    def __init__(self):
        self.jd_instance = DispatchEx('designerstarter.InstanceManager')
        self.jd = None
        self.geometry_editor = None
        self.doc = None
        self.assembly = None
        self.sketch = None
        self.part = None
        self.model = None
        self.study = None
        self.view = None
        self.filepath = None
        self.study_type = None
        self.default_length = None
        self.default_angle = None
        self.visible = True

    def __del__(self):
        self.jd.Quit()

    def open(self, comp_filepath, length_unit='DimMeter', angle_unit='DimDegree', study_type='Transient'):
        self.default_length = length_unit
        self.default_angle = angle_unit
        self.study_type = study_type

        # parse out path and extension of file
        file_name_path, file_extension = os.path.splitext(comp_filepath)
        file_contents = file_name_path.split("\\")
        # extract folder where file resides
        file_path = file_contents[0]
        for i in range(len(file_contents) - 2):
            file_path = file_path + "\\" + file_contents[i + 1]

        if file_extension != '.jproj':
            raise TypeError('Incorrect file extension')
        self.jd = self.jd_instance.GetNamedInstance(comp_filepath, 0)
        self.set_visibility(self.visible)

        # check if file exists
        if os.path.exists(comp_filepath):
            self.jd.Load(comp_filepath)
            self.filepath = comp_filepath
        # if not, check if folder exists
        else:
            if os.path.exists(file_path):
                self.jd.NewProject(comp_filepath)
                self.save_as(comp_filepath)
            # if folder does not exist, just use current directory
            else:
                print('does not exist')
                curr_dir = os.getcwd()
                filename = os.path.basename(comp_filepath)
                self.filepath = curr_dir + '/' + filename
                self.jd.NewProject(comp_filepath)
                self.save_as(comp_filepath)

        self.view = self.jd.View()
        self.jd.GetCurrentModel().RestoreCadLink(True)
        self.geometry_editor = self.jd.CreateGeometryEditor(True)
        self.doc = self.geometry_editor.GetDocument()
        self.assembly = self.doc.GetAssembly()

    def save(self):
        if type(self.filepath) is str:
            self.jd.SaveAs(self.filepath)
        else:
            raise AttributeError('Unable to save file. Use the save_as() function')

    def save_as(self, filepath):
        self.filepath = filepath
        self.save()

    def close(self):
        del self

    def set_visibility(self, visible):
        self.visible = visible
        if self.visible:
            self.jd.Show()
        else:
            self.jd.Hide()

    def draw_line(self, startxy: 'Location2D', endxy: 'Location2D') -> 'TokenDraw':
        if self.part is None:
            self.part = self.create_part()

        start_x = eval(self.default_length)(startxy[0])
        start_y = eval(self.default_length)(startxy[1])
        end_x = eval(self.default_length)(endxy[0])
        end_y = eval(self.default_length)(endxy[1])

        line = self.sketch.CreateLine(start_x, start_y, end_x, end_y)
        return TokenDraw(line, 0)

    def draw_arc(self, centerxy: 'Location2D', startxy: 'Location2D', endxy: 'Location2D') -> 'TokenDraw':
        if self.part is None:
            self.part = self.create_part()

        center_x = eval(self.default_length)(centerxy[0])
        center_y = eval(self.default_length)(centerxy[1])
        start_x = eval(self.default_length)(startxy[0])
        start_y = eval(self.default_length)(startxy[1])
        end_x = eval(self.default_length)(endxy[0])
        end_y = eval(self.default_length)(endxy[1])
        arc = self.sketch.CreateArc(center_x, center_y, start_x, start_y, end_x, end_y)
        return TokenDraw(arc, 1)

    def create_part(self):
        ref1 = self.assembly.GetItem('XY Plane')
        ref2 = self.doc.CreateReferenceFromItem(ref1)
        self.sketch = self.assembly.CreateSketch(ref2)
        partName = 'partDrawing'
        self.sketch.SetProperty('Name', partName)

        self.sketch.OpenSketch()
        ref1 = self.assembly.GetItem(partName)
        ref2 = self.doc.CreateReferenceFromItem(ref1)
        self.assembly.MoveToPart(ref2)
        part = self.assembly.GetItem(partName)

        return part

    def create_model(self, model_name):

        num_models = self.jd.NumModels()
        if num_models == 1:
            model = self.jd.GetCurrentModel()
            model.setName(model_name)
        else:
            for i in range(num_models - 1):
                self.jd.DeleteModel(i)
            model = self.jd.GetCurrentModel()
            model.setName(model_name)

        return model

    def select(self):
        pass

    def prepare_section(self, cs_token: 'CrossSectToken') -> TokenMake:
        # self.validate_attr(cs_token, 'CrossSectToken')
        self.doc.GetSelection().Clear()
        for i in range(len(cs_token.token)):
            for j in range(len(cs_token.token[i])):
                self.doc.GetSelection().Add(self.sketch.GetItem(cs_token.token[i][j].draw_token.GetName()))

        id = self.sketch.NumItems()
        self.sketch.CreateRegions()
        id2 = self.sketch.NumItems()
        visItem = 1
        itemType = 64
        innerCoord1 = cs_token.inner_coord[0]
        innerCoord2 = cs_token.inner_coord[1]

        innerCoord1 = eval(self.default_length)(innerCoord1)
        innerCoord2 = eval(self.default_length)(innerCoord2)

        self.geometry_editor.View().SelectAtCoordinateDlg(innerCoord1, innerCoord2, 0, visItem, itemType)
        region = self.doc.GetSelection().Item(0)
        regionName = region.GetName()

        regionList = ['Region']
        for idx in range(1, id2 - id):
            regionList.append('Region.' + str(idx + 1))

        for idx in range((id2 - id)):
            if regionList[idx] != regionName:
                self.doc.GetSelection().Clear()
                self.doc.GetSelection().Add(self.sketch.GetItem(regionList[idx]))
                self.doc.GetSelection().Delete()

        self.sketch.CloseSketch()

        return region

    def create_study(self, study_name, study_type, model) -> any:
        self.study_type = study_type
        num_studies = self.jd.NumStudies()
        if num_studies == 0:
            study = model.CreateStudy(study_type, study_name)
        else:
            for i in range(num_studies):
                model.DeleteStudy(i)
            study = self.jd.GetCurrentStudy()
            study.SetName(study_name)

        return study

    def extrude(self, name, material: str, depth: float, token=None) -> any:
        depth = eval(self.default_length)(depth)
        ref1 = self.sketch
        extrude_part = self.part.CreateExtrudeSolid(ref1, depth)
        self.part.SetProperty('Name', name)
        sketch_name = name + '_sketch'
        self.sketch.SetProperty('Name', sketch_name)

        self.part = None
        self.doc.SaveModel(True)
        model_name = name + '_model'
        self.model = self.create_model(model_name)

        study_name = name + '_study'
        self.study = self.create_study(study_name, self.study_type, self.model)

        self.set_default_length_unit(self.default_length)
        self.set_default_angle_unit(self.default_angle)

        self.study.SetMaterialByName(name, material)

        return extrude_part

    def set_default_length_unit(self, userUnit):

        if userUnit == 'DimMeter':
            self.default_length = userUnit
            self.model.SetUnitCollection('SI_units')
        else:
            raise Exception('Unsupported length unit')

    def set_default_angle_unit(self, userUnit):

        if userUnit == 'DimDegree':
            self.default_angle = userUnit
            self.model.SetUnitCollection('SI_units')
        else:
            raise Exception('Unsupported angle unit')

    def revolve(self, name, material: str, center: 'Location2D', axis: 'Location2D', angle: float) -> any:
        center = eval(self.default_length, center)
        axis = eval(self.default_length, axis)
        angle = eval(self.default_angle, angle)

        ref1 = self.sketch
        revolve_part = self.part.CreateRevolveSolid(ref1)
        self.part.GetItem('Revolve').setProperty('SpecificRatio', 1)
        self.part.GetItem('Revolve').setProperty('AxisType', '1')
        self.part.GetItem('Revolve').setProperty('AxisPosX', center[0])
        self.part.GetItem('Revolve').setProperty('AxisPosY', center[1])
        self.part.GetItem('Revolve').setProperty('AxisVecX', axis[0])
        self.part.GetItem('Revolve').setProperty('AxisVecY', axis[1])
        self.part.GetItem('Revolve').setProperty('AxisVecZ', 0)
        self.part.GetItem('Revolve').setProperty('Angle', angle)
        self.part.SetProperty('Name', name)
        sketch_name = name + '_sketch'
        self.sketch.SetProperty('Name', sketch_name)

        self.part = None
        self.doc.SaveModel(True)
        model_name = name + '_model'
        self.model = self.create_model(model_name)

        study_name = name + '_study'
        self.study = self.create_study(study_name, self.study_type, self.model)

        self.set_default_length_unit(self.default_length)
        self.set_default_angle_unit(self.default_angle)

        self.study.SetMaterialByName(name, material)
        return revolve_part
