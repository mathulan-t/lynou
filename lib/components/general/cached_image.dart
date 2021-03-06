import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lynou/providers/theme_provider.dart';
import 'package:lynou/services/auth_service.dart';
import 'package:provider/provider.dart';

class CachedImage extends StatefulWidget {
  final String url;
  final BoxFit boxFit;
  final double height;
  final double width;
  final double heightPlaceholder;
  final double widthPlaceholder;

  CachedImage({
    @required this.url,
    this.boxFit,
    this.height,
    this.width,
    this.heightPlaceholder,
    this.widthPlaceholder,
  });

  @override
  _CachedImageState createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  AuthService _authService;

  /// Displays the placeholder until we loaded the image
  Widget _displaysPlaceholder(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    var width;
    var height;

    // Put the placeholder size
    if(widget.widthPlaceholder != null) {
      width = widget.widthPlaceholder;
    }

    if(widget.heightPlaceholder != null) {
      height = widget.heightPlaceholder;
    }

    return Container(
      color: themeProvider.secondBackgroundColor,
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    _authService = Provider.of<AuthService>(context);

    return FutureBuilder<String>(
      future: _authService.getAccessToken(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if(snapshot.data != null) {
          return CachedNetworkImage(
            fit: widget.boxFit == null ? BoxFit.fitWidth : widget.boxFit,
            imageUrl: widget.url,
            width: widget.width != null ? widget.width : null,
            height: widget.height != null ? widget.height : null,
            httpHeaders: {HttpHeaders.authorizationHeader: "Bearer ${snapshot.data}"},
            placeholder: (context, url) => _displaysPlaceholder(context),
          );
        }

        return _displaysPlaceholder(context);
      }
    );
  }
}
