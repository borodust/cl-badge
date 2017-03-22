(in-package :cl-bodge.physics)


(define-constant +precision+ (if ode:+double-precision-p+ 0d0 0f0)
  :test #'=)

(defvar *contact-points-per-collision* 1)


(defclass ode-object (system-foreign-object) ())


(defgeneric direction-of (object))
(defgeneric (setf direction-of) (value object))


(defgeneric collide (this-geom that-geom)
  (:method (this-geom that-geom) t))


(defgeneric filter-contacts (contacts this-geom that-geom)
  (:method (contacts this-geom that-geom) contacts))


(defgeneric contacts-per-collision (this-geom that-geom)
  (:method (this that) *contact-points-per-collision*))



;;;
;;;
;;;
(defclass collidable () ())


(defgeneric collidablep (obj)
  (:method (obj) nil))


(defmethod collidablep ((this collidable))
  t)


(defmethod collide ((this collidable) (that collidable))
  nil)


(definline ode-real (value)
  (float value +precision+))
