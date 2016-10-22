(in-package :cl-user)

(defpackage :cl-bodge.definition
  (:use :cl :asdf))

(in-package :cl-bodge.definition)

(defsystem cl-bodge
  :description "Bodacious Game Engine"
  :version "0.1.0"
  :author "Pavel Korolev"
  :mailto "dev@borodust.org"
  :license "MIT"
  :depends-on (alexandria cl-opengl cl-glfw3 cl-muth sb-cga cffi clode
                          log4cl bordeaux-threads trivial-main-thread cl-openal cl-alc
                          cl-fad local-time blackbird trivial-garbage opticl)
  :serial t
  :components ((:file "packages")
               (:module utils
                        :serial t
                        :components ((:file "utils")))
               (:module math
                        :serial t
                        :components ((:file "types")
                                     (:file "vector")
                                     (:file "matrix")
                                     (:file "matvec")))
               (:module concurrency
                        :serial t
                        :components ((:file "async")
                                     (:file "execution")
                                     (:file "job-queue")))
               (:module memory
                        :serial t
                        :components ((:file "disposable")))
               (:module engine
                        :serial t
                        :components ((:file "properties")
                                     (:file "engine")
                                     (:file "generic-system")
                                     (:file "thread-bound-system")))
               (:module event
                        :serial t
                        :components ((:file "system")))
               (:module host
                        :serial t
                        :components ((:file "events")
                                     (:file "system")))
               (:module graphics
                        :serial t
                        :components ((:file "gl")
                                     (:file "resources")
                                     (:file "renderable")
                                     (:file "buffers")
                                     (:file "vertex-array")
                                     (:file "mesh")
                                     (:file "shading")
                                     (:file "textures")
                                     (:file "system")))
               (:module audio
                        :serial t
                        :components ((:file "al")
                                     (:file "buffer")
                                     (:file "source")
                                     (:file "system")))
               (:module physics
                        :serial t
                        :components ((:file "universe")
                                     (:file "system")
                                     (:file "ode")
                                     (:file "mass")
                                     (:file "rigid-body")
                                     (:file "joints")
                                     (:file "geometry")))
               (:module resources
                        :serial t
                        :components ((:file "shader-source")
                                     (:file "shader-library")
                                     (:file "image")
                                     (:module shaders
                                              :components
                                              ((:file "lighting")))))
               (:module scene
                        :serial t
                        :components ((:file "node")
                                     (:file "scene")
                                     (:file "transformations")
                                     (:file "rendering")
                                     (:file "lighting")))))
