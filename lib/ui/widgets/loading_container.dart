import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:rescu_organization_portal/ui/widgets/size_config.dart';

class LoadingContainer extends StatefulWidget {
  final LoadingController controller;
  final bool blockPopOnLoad;
  final Widget child;

  const LoadingContainer(
      {required this.controller,
      this.blockPopOnLoad = true,
      required this.child,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoadingState();
  }
}

class LoadingController {
  final ValueNotifier<bool> _showNotifier = ValueNotifier(false);

  void show() {
    _showNotifier.value = true;
  }

  void hide() {
    _showNotifier.value = false;
  }

  void dispose() {
    _showNotifier.dispose();
  }
}

class _LoadingState extends State<LoadingContainer> {
  bool _shouldShow = false;

  @override
  void initState() {
    widget.controller._showNotifier.addListener(() {
      setState(() {
        _shouldShow = widget.controller._showNotifier.value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (ctx) {
      if (widget.blockPopOnLoad) {
        return WillPopScope(
            onWillPop: () async {
              return !_shouldShow;
            },
            child: LoadingOverlay(
                isLoading: _shouldShow,
                color: LoaderConfiguration.loaderBackGround,
                progressIndicator: LoaderConfiguration.loaderIndicator(),
                child: widget.child));
      }
      return LoadingOverlay(
          isLoading: _shouldShow,
          color: LoaderConfiguration.loaderBackGround,
          progressIndicator: LoaderConfiguration.loaderIndicator(),
          child: widget.child);
    });
  }
}

class LoaderConfiguration {
  static Color loaderBackGround = Colors.transparent;

  static Widget loaderIndicator() {
    return SizedBox(
      width: 200,
      height: 200,
      child: SimpleDialog(
          backgroundColor: Colors.black54.withOpacity(0.7),
          children: <Widget>[
            Center(
              child: Column(children: [
                SpinKitFadingCircle(
                  color: Colors.white,
                  size: SizeConfig.size(5),
                ),
                Text(
                  "Please Wait....",
                  style: TextStyle(fontSize: SizeConfig.size(1.2)),
                )
              ]),
            )
          ]),
    );
  }
}
