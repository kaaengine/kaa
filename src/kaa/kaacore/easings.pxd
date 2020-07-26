from .vectors cimport CDVec2


cdef extern from "kaacore/easings.h" nogil:
    cdef enum CEasing "kaacore::Easing":
        none "kaacore::Easing::none"
        back_in "kaacore::Easing::back_in"
        back_in_out "kaacore::Easing::back_in_out"
        back_out "kaacore::Easing::back_out"
        bounce_in "kaacore::Easing::bounce_in"
        bounce_in_out "kaacore::Easing::bounce_in_out"
        bounce_out "kaacore::Easing::bounce_out"
        circular_in "kaacore::Easing::circular_in"
        circular_in_out "kaacore::Easing::circular_in_out"
        circular_out "kaacore::Easing::circular_out"
        cubic_in "kaacore::Easing::cubic_in"
        cubic_in_out "kaacore::Easing::cubic_in_out"
        cubic_out "kaacore::Easing::cubic_out"
        elastic_in "kaacore::Easing::elastic_in"
        elastic_in_out "kaacore::Easing::elastic_in_out"
        elastic_out "kaacore::Easing::elastic_out"
        exponential_in "kaacore::Easing::exponential_in"
        exponential_in_out "kaacore::Easing::exponential_in_out"
        exponential_out "kaacore::Easing::exponential_out"
        quadratic_in "kaacore::Easing::quadratic_in"
        quadratic_in_out "kaacore::Easing::quadratic_in_out"
        quadratic_out "kaacore::Easing::quadratic_out"
        quartic_in "kaacore::Easing::quartic_in"
        quartic_in_out "kaacore::Easing::quartic_in_out"
        quartic_out "kaacore::Easing::quartic_out"
        quintic_in "kaacore::Easing::quintic_in"
        quintic_in_out "kaacore::Easing::quintic_in_out"
        quintic_out "kaacore::Easing::quintic_out"
        sine_in "kaacore::Easing::sine_in"
        sine_in_out "kaacore::Easing::sine_in_out"
        sine_out "kaacore::Easing::sine_out"

    double c_ease "kaacore::ease"(const CEasing, const double progress)
    T c_ease_between "kaacore::ease_between"[T](
        const CEasing, const double progress, const T a, const T b
    )
