#ifndef Layer_h
#define Layer_h

#include <string>
#include <gl.h>
#include <map>
#include "ViewState.h"
#include "IDTracker.h"
#include "DebugReporter.h"
#include "TclCommandManager.h"
#include "ScubaWindowToRASTranslator.h"
#include "ScubaToolState.h"
#include "InputState.h"

class LayerStaticTclListener : public DebugReporter, public TclCommandListener {
  public :
    ~LayerStaticTclListener ();

    virtual TclCommandResult
      DoListenToTclCommand ( char* iCommand, int iArgc, char** iArgv );
};


class Layer : public DebugReporter, public IDTracker<Layer>, public TclCommandListener {

  friend class ScubaViewTester;

 public:

  Layer();
  virtual ~Layer();

  // Tell the layer to draw its contents into a GL frame buffer.
  virtual void DrawIntoBuffer( GLubyte* iBuffer, int iWidth, int iHeight,
			       ViewState& iViewState,
			       ScubaWindowToRASTranslator& iTranslator );
  
  // Asks the layer to describe a point of data by adding pairs of
  // labels and values.
  virtual void GetInfoAtRAS ( float iRAS[3],
			   std::map<std::string,std::string>& iLabelValues );
  
  // Should return a type description unique to the subclass.
  virtual std::string GetTypeDescription() { return "BaseLayer"; }

  virtual TclCommandResult
    DoListenToTclCommand ( char* isCommand, int iArgc, char** iasArgv );

  void SetLabel( std::string isLabel ) { msLabel = isLabel; }
  std::string GetLabel() { return msLabel; }

  void SetOpacity( float iOpacity ) { mOpacity = iOpacity; }
  float GetOpacity() { return mOpacity; }

  void SetWidth( int iWidth ) { mWidth = iWidth; }
  void SetHeight( int iHeight ) { mHeight = iHeight; }

  virtual void HandleTool ( float iRAS[3],
			    ScubaToolState& iTool, InputState& iInput );

  // Redisplay posters.
  void RequestRedisplay() { mbPostRedisplay = true; }
  bool WantRedisplay() const { return mbPostRedisplay; }
  void RedisplayPosted() { mbPostRedisplay = false; }

 protected:

  int mWidth;
  int mHeight;

  std::string msLabel;
  
  float mOpacity;

  static bool mbRegisteredStaticListener;
  static LayerStaticTclListener mStaticListener;

  // Redisplay requested flag.
  bool mbPostRedisplay;
};



#endif
