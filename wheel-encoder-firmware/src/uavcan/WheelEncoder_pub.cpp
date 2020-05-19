#include <ch.h>
#include <hal.h>
#include <cvra/odometry/WheelEncoder.hpp>
#include <encoder.h>

#include "WheelEncoder_pub.hpp"

void wheel_encoder_publish(uavcan::INode& node)
{
    static uavcan::Publisher<cvra::odometry::WheelEncoder> pub(node);

    auto msg = cvra::odometry::WheelEncoder();

    // TODO(mi): read encoders and set data fields
    msg.right_encoder_raw = 42;
    msg.left_encoder_raw = -42;

    pub.broadcast(msg);
}
