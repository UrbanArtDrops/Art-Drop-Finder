import 'dart:typed_data';

import 'package:image/image.dart' as img;

class SanitizedImage {
  final Uint8List bytes;
  final String filename;

  const SanitizedImage({
    required this.bytes,
    required this.filename,
  });
}

SanitizedImage stripImageMetadata(Uint8List bytes, String filename) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    final stripped = _stripKnownMetadataSegments(bytes);
    return SanitizedImage(bytes: stripped, filename: filename);
  }

  final oriented = img.bakeOrientation(decoded);
  final extension = _extension(filename);
  final usePng = extension == 'png' || oriented.hasAlpha;
  if (usePng) {
    return SanitizedImage(
      bytes: Uint8List.fromList(img.encodePng(oriented)),
      filename: _replaceExtension(filename, 'png'),
    );
  }

  return SanitizedImage(
    bytes: Uint8List.fromList(img.encodeJpg(oriented, quality: 92)),
    filename: _replaceExtension(filename, 'jpg'),
  );
}

Uint8List _stripKnownMetadataSegments(Uint8List bytes) {
  if (_isJpeg(bytes)) {
    return _stripJpegMetadataSegments(bytes);
  }
  if (_isPng(bytes)) {
    return _stripPngMetadataChunks(bytes);
  }
  return bytes;
}

bool _isJpeg(Uint8List bytes) {
  return bytes.length >= 4 && bytes[0] == 0xFF && bytes[1] == 0xD8;
}

bool _isPng(Uint8List bytes) {
  if (bytes.length < 8) {
    return false;
  }
  const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  for (var i = 0; i < signature.length; i++) {
    if (bytes[i] != signature[i]) {
      return false;
    }
  }
  return true;
}

Uint8List _stripJpegMetadataSegments(Uint8List bytes) {
  if (!_isJpeg(bytes)) {
    return bytes;
  }
  final output = BytesBuilder(copy: false);
  output.add(bytes.sublist(0, 2));
  var index = 2;

  while (index < bytes.length) {
    if (bytes[index] != 0xFF || index + 1 >= bytes.length) {
      output.add(bytes.sublist(index));
      break;
    }
    final marker = bytes[index + 1];
    if (marker == 0xDA) {
      output.add(bytes.sublist(index));
      break;
    }
    if (marker == 0xD9) {
      output.add(bytes.sublist(index, index + 2));
      break;
    }
    if (marker == 0xD8 ||
        marker == 0x01 ||
        (marker >= 0xD0 && marker <= 0xD7)) {
      output.add(bytes.sublist(index, index + 2));
      index += 2;
      continue;
    }
    if (index + 3 >= bytes.length) {
      output.add(bytes.sublist(index));
      break;
    }
    final length = (bytes[index + 2] << 8) | bytes[index + 3];
    final segmentEnd = index + 2 + length;
    if (length < 2 || segmentEnd > bytes.length) {
      output.add(bytes.sublist(index));
      break;
    }
    final isAppSegment = marker >= 0xE0 && marker <= 0xEF;
    final isMetadataSegment =
        marker == 0xFE || (isAppSegment && marker != 0xE0);
    if (!isMetadataSegment) {
      output.add(bytes.sublist(index, segmentEnd));
    }
    index = segmentEnd;
  }

  return output.takeBytes();
}

Uint8List _stripPngMetadataChunks(Uint8List bytes) {
  if (!_isPng(bytes)) {
    return bytes;
  }
  final output = BytesBuilder(copy: false);
  output.add(bytes.sublist(0, 8));
  var index = 8;

  while (index + 8 <= bytes.length) {
    final length = (bytes[index] << 24) |
        (bytes[index + 1] << 16) |
        (bytes[index + 2] << 8) |
        bytes[index + 3];
    final typeStart = index + 4;
    final dataStart = index + 8;
    final dataEnd = dataStart + length;
    final crcEnd = dataEnd + 4;
    if (length < 0 || crcEnd > bytes.length) {
      return bytes;
    }
    final type = String.fromCharCodes(bytes.sublist(typeStart, typeStart + 4));
    if (!_isPngMetadataChunk(type)) {
      output.add(bytes.sublist(index, crcEnd));
    }
    index = crcEnd;
    if (type == 'IEND') {
      break;
    }
  }

  return output.takeBytes();
}

bool _isPngMetadataChunk(String type) {
  switch (type) {
    case 'eXIf':
    case 'iTXt':
    case 'tEXt':
    case 'zTXt':
    case 'iCCP':
      return true;
  }
  return false;
}

String _extension(String filename) {
  final trimmed = filename.trim();
  final index = trimmed.lastIndexOf('.');
  if (index <= 0 || index == trimmed.length - 1) {
    return '';
  }
  return trimmed.substring(index + 1).toLowerCase();
}

String _replaceExtension(String filename, String extension) {
  final trimmed = filename.trim();
  if (trimmed.isEmpty) {
    return 'drop_upload.$extension';
  }
  final index = trimmed.lastIndexOf('.');
  if (index <= 0) {
    return '$trimmed.$extension';
  }
  return '${trimmed.substring(0, index)}.$extension';
}
