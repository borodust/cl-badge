(in-package :cl-bodge.asdf)


(defpackage :cl-bodge.physics
  (:use :cl-bodge.engine :cl-bodge.utils
        :cl :local-time :bodge-ode :autowrap :plus-c)
  (:nicknames :ge.phx)
  (:export physics-system
           physics
           observe-universe
           gravity

           contact-position
           contact-normal
           contact-depth

           make-rigid-body
           position-of
           rotation-of
           linear-velocity-of
           angular-velocity-of
           mass-of
           apply-force

           make-ball-joint
           make-hinge-joint
           make-slider-joint
           make-universal-joint
           make-double-hinge-joint
           make-angular-motor-joint

           collide
           filter-contacts
           contacts-per-collision
           collidable
           collidablep
           sphere-geom
           box-geom
           plane-geom
           ray-geom
           direction-of
           bind-geom

           make-box-mass
           make-sphere-mass))
