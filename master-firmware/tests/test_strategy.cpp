#include <CppUTest/TestHarness.h>
#include <vector>
#include <array>

#include "strategy/goals.h"
#include "strategy/actions.h"

bool dummy_execute(goap::Action<RobotState>* action, RobotState& state)
{
    action->plan_effects(state);
    return true;
}

struct IndexArms : actions::IndexArms {
    bool execute(RobotState& state) { return dummy_execute(this, state); }
};
struct RetractArms : actions::RetractArms {
    bool execute(RobotState& state) { return dummy_execute(this, state); }
};
struct TakePuck : actions::TakePuck {
    TakePuck(size_t id) : actions::TakePuck(id) {}
    bool execute(RobotState& state) { return dummy_execute(this, state); }
};
struct DepositPuck : actions::DepositPuck {
    DepositPuck(PuckColor color) : actions::DepositPuck(color) {}
    bool execute(RobotState& state) { return dummy_execute(this, state); }
};

TEST_GROUP (Strategy) {
    RobotState state = initial_state();

    IndexArms index_arms;
    RetractArms retract_arms;
    TakePuck take_pucks[3] = {{0}, {1}, {2}};
    DepositPuck deposit_puck[2] = {{PuckColor_RED}, {PuckColor_GREEN}};

    std::vector<goap::Action<RobotState>*> availableActions()
    {
        return std::vector<goap::Action<RobotState>*>{
            &index_arms,
            &retract_arms,
            &take_pucks[0],
            &take_pucks[1],
            &take_pucks[2],
            &deposit_puck[0],
            &deposit_puck[1],
        };
    }

    int compute_and_execute_plan(goap::Goal<RobotState> & goal, RobotState & state)
    {
        const int max_path_len = 40;
        goap::Action<RobotState>* path[max_path_len] = {nullptr};
        goap::Planner<RobotState, GOAP_SPACE_SIZE> planner;
        auto actions = availableActions();

        int len = planner.plan(state, goal, actions.data(), actions.size(), path, max_path_len);
        for (int i = 0; i < len; i++) {
            path[i]->execute(state);
        }

        return len;
    }
};

TEST(Strategy, CanInitArms)
{
    InitGoal init_goal;

    int len = compute_and_execute_plan(init_goal, state);

    CHECK_TRUE(len > 0);
    CHECK_TRUE(init_goal.is_reached(state));
}

TEST(Strategy, CanFillRedPuckArea)
{
    RedPucksGoal goal;

    int len = compute_and_execute_plan(goal, state);

    CHECK_TRUE(len > 0);
    CHECK_TRUE(goal.is_reached(state));
}

TEST(Strategy, CanFillGreenPuckArea)
{
    GreenPucksGoal goal;

    int len = compute_and_execute_plan(goal, state);

    CHECK_TRUE(len > 0);
    CHECK_TRUE(goal.is_reached(state));
}
