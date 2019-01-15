(cl:in-package :cl-bodge.graphics)


(declaim (special *graphics-context*))


(defclass graphics-context (dispatching disposable)
  ((rendering-context :initform nil)
   (state :initform (make-instance 'context-state))
   (supplementary-framebuffer :initform nil :reader %supplementary-framebuffer-of)
   (depth-stencil-renderbuffer :initform nil :reader %depth-stencil-renderbuffer-of)
   (framebuffer-width :initform 0 :reader %framebuffer-width-of)
   (framebuffer-height :initform 0 :reader %framebuffer-height-of)
   (executor :initform (acquire-executor :single-threaded-p t :exclusive-p t) :reader %executor-of)))


(defun initialize-graphics-context (this)
  (with-slots (rendering-context state supplementary-framebuffer depth-stencil-renderbuffer) this
    (bind-rendering-context (if (eq rendering-context t)
                                nil
                                rendering-context))
    (with-current-state-slice (state)
      (gx.state:enable :blend
                       :cull-face
                       :depth-test
                       :program-point-size)
      (if (featurep :bodge-gl2)
          (progn
            (gx.state:enable :texture-cube-map-seamless)
            (setf supplementary-framebuffer (gl:gen-framebuffer)
                  depth-stencil-renderbuffer (gl:gen-renderbuffer)))
          (progn
            (setf supplementary-framebuffer t
                  depth-stencil-renderbuffer t)))
      (gx.state:disable :scissor-test
                        :stencil-test)
      (gx.state:cull-face :back)
      (gx.state:front-face :ccw)
      (gx.state:clear-color 1.0 1.0 1.0 1.0)
      (gx.state:color-mask t t t t)
      (gx.state:clear-depth 1.0)
      (gx.state:blend-func :src-alpha :one-minus-src-alpha)
      (gx.state:blend-func-separate :src-alpha :one-minus-src-alpha
                                    :one :zero)
      (gx.state:clear-stencil 0)
      (gx.state:stencil-mask #xffffffff)
      (gx.state:stencil-func :always 0 #xffffffff)
      (gx.state:stencil-op :keep :keep :keep)
      (gx.state:pixel-store :unpack-alignment 1)
      this)))


(defun execute-with-context (ctx task &rest args &key &allow-other-keys)
  (with-slots (executor) ctx
    (apply #'execute executor task args)))


(defun ~rendering-context-initialization (context &optional (main t))
  (with-slots (rendering-context) context
    (for-host ()
      (setf rendering-context (if main
                                  t
                                  (make-shared-rendering-context))))))


(defun ~shared-context-initialization (context)
  (with-slots (rendering-context) context
    (-> (graphics) ()
      (release-rendering-context)
      (mt:wait-with-latch (latch)
        (run (>> (~rendering-context-initialization context nil)
                 (instantly () (mt:open-latch latch)))))
      (bind-rendering-context))))


(defmethod initialization-flow list ((this graphics-context) &key main)
  (with-slots (rendering-context) this
    (>> (->> ()
          (if main
              (~rendering-context-initialization this)
              (~shared-context-initialization this)))
        (%> ()
          (flet ((%init ()
                   (initialize-graphics-context this)
                   (run (concurrently () (continue-flow)))))
            (execute-with-context this #'%init :important-p t :priority :highest))))))


(defun %graphics-context-destructuring-flow (rendering-context
                                             supplementary-framebuffer
                                             depth-stencil-renderbuffer
                                             executor)
  (>> (%> ()
        (flet ((clearup ()
                 (unwind-protect
                      (progn
                        (unless (featurep :bodge-gl2)
                          (gl:delete-framebuffers (list supplementary-framebuffer))
                          (gl:delete-renderbuffers (list depth-stencil-renderbuffer)))
                        (release-rendering-context))
                   (run (concurrently () (continue-flow))))))
          (execute executor #'clearup)))
      (instantly ()
        (unless (eq rendering-context t)
          (dispose rendering-context))
        (release-executor executor))))


(defun graphics-context-destructuring-flow (context)
  (with-slots (rendering-context
               supplementary-framebuffer
               depth-stencil-renderbuffer
               executor)
      context
    (%graphics-context-destructuring-flow rendering-context supplementary-framebuffer depth-stencil-renderbuffer executor)))


(define-destructor graphics-context (rendering-context
                                     supplementary-framebuffer
                                     depth-stencil-renderbuffer
                                     executor)
  (run (%graphics-context-destructuring-flow rendering-context supplementary-framebuffer depth-stencil-renderbuffer executor)))


(defun update-context-framebuffer-size (width height &optional (context *graphics-context*))
  (with-slots (framebuffer-width framebuffer-height) context
    (setf framebuffer-width width
          framebuffer-height height)))


(defun reset-context-viewport (&optional (context *graphics-context*))
  (with-slots (framebuffer-width framebuffer-height) context
    (gl:viewport 0 0 framebuffer-width framebuffer-height)))


(defun reset-context-state (&optional (context *graphics-context*))
  (with-slots (state) context
    (reset-all-context-state state)))
