#ifndef ACTUATOR_BOARD_EMULATOR_H
#define ACTUATOR_BOARD_EMULATOR_H

#include <thread>
#include <memory>
#include <absl/synchronization/mutex.h>
#include <cvra/actuator/Command.hpp>
#include <uavcan_linux/uavcan_linux.hpp>
#include "uavcan_node.h"

class ActuatorBoardEmulator {
    uavcan_linux::SystemClock clock;
    uavcan_linux::SocketCanDriver driver;
    std::unique_ptr<Node> node;
    std::thread can_thread;

    using CommandSub = uavcan::Subscriber<cvra::actuator::Command>;
    std::unique_ptr<CommandSub> command_sub;

    absl::Mutex lock;

public:
    ActuatorBoardEmulator(std::string can_iface, std::string board_name, int node_number);
    void start();

private:
    void spin();
};

#endif
