#include "actuator_board_emulator.h"
#include <thread>
#include <error/error.h>

ActuatorBoardEmulator::ActuatorBoardEmulator(std::string can_iface, std::string board_name, int node_number)
    : driver(clock)
{
    NOTICE("Actuator board emulator on %s", can_iface.c_str());
    if (driver.addIface(can_iface) < 0) {
        ERROR("Failed to add iface %s", can_iface.c_str());
    }
    node = std::make_unique<Node>(driver, clock);
    node->setHealthOk();
    node->setModeOperational();
    if (!node->setNodeID(node_number)) {
        ERROR("Invalid node number %d", node_number);
    }
    node->setName(board_name.c_str());

    command_sub = std::make_unique<ActuatorBoardEmulator::CommandSub>(*node);
    command_sub->start([&](const uavcan::ReceivedDataStructure<cvra::actuator::Command>& msg) {
        if (msg.node_id != node->getNodeID().get()) {
            DEBUG("dropping message. msg.node_id is %d, ours is %d", msg.node_id, node->getNodeID().get());
            return;
        }

        // TODO: Do something with the message
        NOTICE("arm position: %.3f", msg.servo_trajectories[0].position);
    });
}

void ActuatorBoardEmulator::start()
{
    std::thread new_thread(&ActuatorBoardEmulator::spin, this);
    std::swap(new_thread, can_thread);
}

void ActuatorBoardEmulator::spin()
{
    node->start();
    while (true) {
        const int res = node->spin(uavcan::MonotonicDuration::fromMSec(1000));
        if (res < 0) {
            WARNING("UAVCAN failure: %d", res);
        }
    }
}
