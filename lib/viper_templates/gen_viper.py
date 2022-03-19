import operator
import os
from enum import Enum
import viper_config

class CodeGenType(Enum):
    all = 0,
    scene = 1,
    usecase = 2,
    repo = 3,
    entity = 4,
    request = 5,
    repsonse = 6

    def allValues(self):
        return [self.scene, self.usecase, self.repo, self.entity, \
            self.request, self.repsonse]

class ViperGenerator:
    def __init__(self):
        self.projectName = ""
        self.projectDirOutput = ""
        self.sceneName = ""
        self.sceneNamePath = ""

    #-----------------------------------
    # Generate viper codes
    #-----------------------------------
    def generate(self):
        if not self.__checkConfig():
            exit

        self.__genDartFile([CodeGenType.all])

    ##===================================
    ## Private Methods
    ##===================================

    #-----------------------------------
    # Check config
    #-----------------------------------
    def __checkConfig(self):
        self.projectName = viper_config.project_name
        print("projectName = " + self.projectName)
        if self.projectName is None or not self.projectName: 
            print("please set project name.")
            return False

        self.projectDirOutput = viper_config.project_dir_output
        print("projectDirOutput = " + self.projectDirOutput)
        if self.projectDirOutput is None or not self.projectDirOutput: 
            print("please set project output dir.")
            return False

        self.sceneName = viper_config.scene_name__class
        print("moduleName = " + self.sceneName)
        if self.sceneName is None or not self.sceneName: 
            print("please set module name.")

        self.sceneNamePath = viper_config.scene_name__path
        print("moduleNamePath = " + self.sceneNamePath)
        if self.sceneNamePath is None or not self.sceneNamePath: 
            print("please set module path.")

        self.useCaseNamePath = viper_config.usecase_name__path
        self.useCaseName = viper_config.usecase_name__class

        self.entityNamePath = viper_config.entity_name__path
        self.entityName = viper_config.entity_name__class

        self.repoNamePath = viper_config.repo_name__path
        self.repoName = viper_config.repo_name__class

        self.requestNamePath = viper_config.request_name__path
        self.requestName = viper_config.request_name__class

        self.responseNamePath = viper_config.response_name__path
        self.responseName = viper_config.response_name__class

        return True

    #
    # Generates dart classes for their viper templates.
    #
    def __genDartFile(self, codeTypes):

        templateRootPath = "templates/lib/"
        if not os.path.exists(templateRootPath):
            print("Viper templates path({0}) does not exist!".format(templateRootPath))
            return

        # preprocess: decides `_codeTypes` from parameter `codeTypes`
        _codeTypes = []
        if codeTypes is None or len(codeTypes):
            exit
        if operator.contains(codeTypes, CodeGenType.all):
            _codeTypes = CodeGenType.allValues(CodeGenType)
        else:
            _codeTypes = codeTypes

        # preprocess: decides template path/output path
        codeGenInfos = []

        for codeType in _codeTypes:
            if codeType == CodeGenType.all:
                break
            elif codeType == CodeGenType.scene:
                # scene:page
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "scene/scene_name/page.dart.in"
                codeGenInfo["out_path"] = "scene/{{scene_name.path}}/{{scene_name.path}}_page.dart"
                codeGenInfos.append(codeGenInfo)
                # scene:pageBuilder
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "scene/scene_name/page_builder.dart.in"
                codeGenInfo["out_path"] = "scene/{{scene_name.path}}/{{scene_name.path}}_page_builder.dart"
                codeGenInfos.append(codeGenInfo)
                # scene:presenter
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "scene/scene_name/presenter.dart.in"
                codeGenInfo["out_path"] = "scene/{{scene_name.path}}/{{scene_name.path}}_presenter.dart"
                codeGenInfos.append(codeGenInfo)
                # scene:presenter_output
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "scene/scene_name/presenter_output.dart.in"
                codeGenInfo["out_path"] = "scene/{{scene_name.path}}/{{scene_name.path}}_presenter_output.dart"
                codeGenInfos.append(codeGenInfo)
                # scene:router
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "scene/scene_name/router.dart.in"
                codeGenInfo["out_path"] = "scene/{{scene_name.path}}/{{scene_name.path}}_router.dart"
                codeGenInfos.append(codeGenInfo)
                # scene/foundation:screen_route_manager
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "scene/foundation/screen_route_manager.dart.in"
                codeGenInfo["out_path"] = "scene/foundation/screen_route_manager.dart.gen"
                codeGenInfos.append(codeGenInfo)
                # scene/foundation/page:screen_route_enums
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "scene/foundation//page/screen_route_enums.dart.in"
                codeGenInfo["out_path"] = "scene/foundation//page/screen_route_enums.dart.gen"
                codeGenInfos.append(codeGenInfo)
            elif codeType == CodeGenType.usecase:
                # usecase
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "domain/usecases/usecase.dart.in"
                codeGenInfo["out_path"] = "domain/usecases/{{usecase_name.path}}_usecase.dart"
                codeGenInfos.append(codeGenInfo)
                # usecase_output
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "domain/usecases/usecase_output.dart.in"
                codeGenInfo["out_path"] = "domain/usecases/{{usecase_name.path}}_usecase_output.dart"
                codeGenInfos.append(codeGenInfo)
            elif codeType == CodeGenType.entity:
                # entity
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "domain/entities/entity.dart.in"
                codeGenInfo["out_path"] = "domain/entities/{{entity_name.path}}_item.dart"
                codeGenInfos.append(codeGenInfo)
            elif codeType == CodeGenType.repo:
                # domain/repositories
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "domain/repositories/repository.dart.in"
                codeGenInfo["out_path"] = "domain/repositories/{{repo_name.path}}_repository.dart"
                codeGenInfos.append(codeGenInfo)
                # data/repositories
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "data/repositories/repository.dart.in"
                codeGenInfo["out_path"] = "data/repositories/{{repo_name.path}}_repository.dart"
                codeGenInfos.append(codeGenInfo)
            elif codeType == CodeGenType.request:
                # request parameter
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "networking/request/parameter.dart.in"
                codeGenInfo["out_path"] = "networking/request/{{request_name.path}}_parameter.dart"
                codeGenInfos.append(codeGenInfo)
            elif codeType == CodeGenType.repsonse:
                # response item
                codeGenInfo = {}
                codeGenInfo["type"] = codeType
                codeGenInfo["in_path"] = "networking/response/response.dart.in"
                codeGenInfo["out_path"] = "networking/response/{{response_name.path}}_response.dart"
                codeGenInfos.append(codeGenInfo)

        # read template dart file, then replace some strings,
        # finally save replaced text as new dart file(.dart)
        def __genCodeFlg(classNamePath, className):
            if classNamePath is None or not classNamePath:
                return False
            if className is None or not className:
                return False
            return True

        print("Generates the following {0} dart files...".format(len(codeGenInfos)))
        for idx, codeInfo in enumerate(codeGenInfos):
            inPath = templateRootPath + codeInfo["in_path"]
            if not os.path.exists(inPath):
                continue
            
            with open(inPath, "r") as srcDartFile:
                outDartText = ""
                dartText = srcDartFile.read()
                outDartText = dartText.replace("{{project_name}}", self.projectName)
                if codeInfo["type"] == CodeGenType.scene and __genCodeFlg(self.sceneNamePath, self.sceneName):
                    codeInfo["out_path"] = codeInfo["out_path"].replace("{{scene_name.path}}", self.sceneNamePath)
                    outDartText = outDartText.replace("{{scene_name.path}}", self.sceneNamePath)
                    outDartText = outDartText.replace("{{scene_name.class}}", self.sceneName)
                    outDartText = outDartText.replace("{{usecase_name.path}}", self.useCaseNamePath)
                    outDartText = outDartText.replace("{{usecase_name.class}}", self.useCaseName)
                    outDartText = outDartText.replace("{{router_name_enum}}", self.sceneName)
                elif codeInfo["type"] == CodeGenType.usecase and __genCodeFlg(self.useCaseNamePath, self.useCaseName):
                    codeInfo["out_path"] = codeInfo["out_path"].replace("{{usecase_name.path}}", self.useCaseNamePath)
                    outDartText = outDartText.replace("{{usecase_name.path}}", self.useCaseNamePath)
                    outDartText = outDartText.replace("{{usecase_name.class}}", self.useCaseName)
                    outDartText = outDartText.replace("{{repo_name.path}}", self.repoNamePath)
                    outDartText = outDartText.replace("{{repo_name.class}}", self.repoName)
                elif codeInfo["type"] == CodeGenType.entity and __genCodeFlg(self.entityNamePath, self.entityName):
                    codeInfo["out_path"] = codeInfo["out_path"].replace("{{entity_name.path}}", self.entityNamePath)
                    outDartText = outDartText.replace("{{entity_name.path}}", self.entityNamePath)
                    outDartText = outDartText.replace("{{entity_name.class}}", self.entityName)
                elif codeInfo["type"] == CodeGenType.repo and __genCodeFlg(self.repoNamePath, self.repoName):
                    codeInfo["out_path"] = codeInfo["out_path"].replace("{{repo_name.path}}", self.repoNamePath)
                    outDartText = outDartText.replace("{{repo_name.path}}", self.repoNamePath)
                    outDartText = outDartText.replace("{{repo_name.class}}", self.repoName)
                    outDartText = outDartText.replace("{{entity_name.path}}", self.entityNamePath)
                    outDartText = outDartText.replace("{{entity_name.class}}", self.entityName)
                    outDartText = outDartText.replace("{{request_name.path}}", self.requestNamePath)
                    outDartText = outDartText.replace("{{request_name.class}}", self.requestName)
                    outDartText = outDartText.replace("{{response_name.path}}", self.responseNamePath)
                    outDartText = outDartText.replace("{{response_name.class}}", self.responseName)
                elif codeInfo["type"] == CodeGenType.request and __genCodeFlg(self.requestNamePath, self.requestName):
                    codeInfo["out_path"] = codeInfo["out_path"].replace("{{request_name.path}}", self.requestNamePath)
                    outDartText = outDartText.replace("{{request_name.path}}", self.requestNamePath)
                    outDartText = outDartText.replace("{{request_name.class}}", self.requestName)
                elif codeInfo["type"] == CodeGenType.repsonse and __genCodeFlg(self.responseNamePath, self.responseName):
                    codeInfo["out_path"] = codeInfo["out_path"].replace("{{response_name.path}}", self.responseNamePath)
                    outDartText = outDartText.replace("{{response_name.path}}", self.responseNamePath)
                    outDartText = outDartText.replace("{{response_name.class}}", self.responseName)
                
                srcDartFile.close()   

                if not outDartText: continue

                outPath = self.projectDirOutput + codeInfo["out_path"]
                os.makedirs(os.path.dirname(outPath), exist_ok=True)
                print("file[{0}] = {1}".format(idx + 1, outPath.replace("../", "")))
                with open(outPath, "w") as outDartFile:
                    outDartFile.write(outDartText)
                    outDartFile.close()

#
# module entry
#
viperGen = ViperGenerator()
viperGen.generate()