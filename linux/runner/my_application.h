#ifndef FLUTTER_MY_APPLICATION_H_
#define FLUTTER_MY_APPLICATION_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(MyApplication, my_application, MY, APPLICATION,
                     GtkApplication)

/**
 * myapplicationnew:
 *
 * creates a new flutter-based application.
 *
 * returns: a new #myapplication.
 */
MyApplication* my_application_new();

#endif  // fluttermyapplicationh
