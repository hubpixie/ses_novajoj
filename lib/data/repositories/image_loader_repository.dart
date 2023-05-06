import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path/path.dart';
import 'package:ses_novajoj/domain/entities/image_loader_item.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/domain/repositories/image_loader_repository.dart';

class ImageLoaderRepositoryImpl extends ImageLoaderRepository {
  // sigleton
  static final ImageLoaderRepositoryImpl _instance =
      ImageLoaderRepositoryImpl._internal();
  ImageLoaderRepositoryImpl._internal();
  factory ImageLoaderRepositoryImpl() => _instance;

  @override
  Future<bool> saveNetworkMedia(
      {required FetchImageLoaderRepoInput input}) async {
    try {
      // download and save
      File tempFile =
          await DefaultCacheManager().getSingleFile(input.mediaUrlString);

      // Add to Gallery/Cameraroll
      await ImageGallerySaver.saveFile(tempFile.path);
      log.info('Image is saved!');
      // tempFile.delete();
      return true;
    } catch (error) {
      log.info('saveNetworkMedia is failed due to $error');
      return false;
    }
  }

  @override
  Future<ImageLoaderItem> fetchImageInfo(
      {required FetchImageLoaderRepoInput input}) async {
    NovaImageInfo imageInfo = NovaImageInfo();
    try {
      // download
      File imgFile =
          await DefaultCacheManager().getSingleFile(input.mediaUrlString);

      Size size = await ImageSizeGetter.getSizeAsync(
          AsyncImageInput.input(FileInput(imgFile)));

      // set imageInfo
      imageInfo.displayName = (String name1, String name2) {
        return StringUtil().substring(name1, start: '', end: '.') + name2;
      }(_getImageFileName(input: input), extension(imgFile.path));
      imageInfo.filename = imgFile.path;
      imageInfo.filesize = (await imgFile.length()).toDouble();
      imageInfo.imageWidth = size.width.toDouble();
      imageInfo.imageHeight = size.height.toDouble();
    } catch (error) {
      log.info('fetchImageInfo is failed due to $error');
      imageInfo.displayName = '';
      imageInfo.filename = '';
      imageInfo.filesize = 0;
      imageInfo.imageWidth = 0;
      imageInfo.imageHeight = 0;
    }

    return ImageLoaderItem(imageInfo: imageInfo);
  }

  String _getImageFileName({required FetchImageLoaderRepoInput input}) {
    String str = StringUtil().lastSegment(input.mediaUrlString);
    if (str.length > 22) {
      return str.substring(0, 16) + str.substring(str.length - 6, str.length);
    }
    return str;
  }
}
