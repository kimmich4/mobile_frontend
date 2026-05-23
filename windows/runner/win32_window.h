#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

// a class abstraction for a high dpi-aware win32 window. intended to be
// inherited from by classes that wish to specialize with custom
// rendering and input handling
class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int x, unsigned int y) : x(x), y(y) {}
  };

  struct Size {
    unsigned int width;
    unsigned int height;
    Size(unsigned int width, unsigned int height)
        : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  // creates a win32 window with |title| that is positioned and sized using
  // |origin| and |size|. new windows are created on the default monitor. window
  // sizes are specified to the os in physical pixels, hence to ensure a
  // consistent size this function will scale the inputted width and height as
  // as appropriate for the default monitor. the window is invisible until
  // |show| is called. returns true if the window was created successfully.
  bool Create(const std::wstring& title, const Point& origin, const Size& size);

  // show the current window. returns true if the window was successfully shown.
  bool Show();

  // release os resources associated with window.
  void Destroy();

  // inserts |content| into the window tree.
  void SetChildContent(HWND content);

  // returns the backing window handle to enable clients to set icon and other
  // window properties. returns nullptr if the window has been destroyed.
  HWND GetHandle();

  // if true, closing this window will quit the application.
  void SetQuitOnClose(bool quit_on_close);

  // return a rect representing the bounds of the current client area.
  RECT GetClientArea();

 protected:
  // processes and route salient window messages for mouse handling,
  // size change and dpi. delegates handling of these to member overloads that
  // inheriting classes can handle.
  virtual LRESULT MessageHandler(HWND window,
                                 UINT const message,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

  // called when createandshow is called, allowing subclass window-related
  // setup. subclasses should return false if setup fails.
  virtual bool OnCreate();

  // called when destroy is called.
  virtual void OnDestroy();

 private:
  friend class WindowClassRegistrar;

  // os callback called by message pump. handles the wmnccreate message which
  // is passed when the non-client area is being created and enables automatic
  // non-client dpi scaling so that the non-client area automatically
  // responds to changes in dpi. all other messages are handled by
  // messagehandler.
  static LRESULT CALLBACK WndProc(HWND const window,
                                  UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept;

  // retrieves a class instance pointer for |window|
  static Win32Window* GetThisFromHandle(HWND const window) noexcept;

  // update the window frame's theme to match the system theme.
  static void UpdateTheme(HWND const window);

  bool quit_on_close_ = false;

  // window handle for top level window.
  HWND window_handle_ = nullptr;

  // window handle for hosted content.
  HWND child_content_ = nullptr;
};

#endif  // runnerwin32windowh
