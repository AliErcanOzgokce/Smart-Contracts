// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

// @author Ali Ercan Ozgokce
// @title LearnToEarn
contract LearnToEarn {

    //-------------------------- EVENTS --------------------------

    // User Events

    /// @notice Emitted when a user is registered in the contract
    /// @param _user The address of the registered user
    /// @param timeInfo The time the user was registered
    event UserRegistered(
        address _user,
        uint256 timeInfo
    );

    /// @notice Emitted when a user is deleted from the contract
    /// @param _user The address of the deleted user
    /// @param timeInfo The time the user was deleted
    event UserDeleted(
        address _user,
        uint256 timeInfo
    );

    /// @notice Emitted when a user is suspended from the contract
    /// @param _user The address of the suspended user
    /// @param timeInfo The time the user was suspended
    event UserSuspended(
        address _user,
        uint256 timeInfo
    );


    /// @notice Emitted when a user is unsuspended from the contract
    /// @param _user The address of the unsuspended user
    /// @param timeInfo The time the user was unsuspended
    event UserUnsuspended(
        address _user,
        uint256 timeInfo
    );

    /// @notice Emitted when a user attempts a task
    /// @param _user The address of the user attempting the task
    /// @param _educator The address of the educator who created the task
    /// @param _learningPathId The ID of the learning path the task is associated with
    /// @param _taskId The ID of the task being attempted
    /// @param timeInfo The time the task was attempted
    event UserAttemptedTask(
        address _user,
        address _educator,
        uint16 _learningPathId,
        uint16 _taskId,
        uint256 timeInfo
    );

    // Educator Events

    /// @notice Emitted when an educator is added to the contract
    /// @param _educator The address of the added educator
    /// @param timeInfo The time the educator was added
    event EducatorAdded(
        address _educator,
        uint256 timeInfo
    );

    /// @notice Emitted when an educator is deleted from the contract
    /// @param _educator The address of the deleted educator
    /// @param timeInfo The time the educator was deleted
    event EducatorDeleted(
        address _educator,
        uint256 timeInfo
    );

    /// @notice Raises an event to indicate that a task attempt by a user has been verified by an educator
    /// @param _user The address of the user who attempted the task
    /// @param _learningPathId The id of the learning path the task belongs to
    /// @param _taskId The id of the task that was attempted
    /// @param _xpEarned The amount of experience points earned by the user
    /// @param _educator The address of the educator who verified the task attempt
    /// @param timeInfo The time the task attempt was verified
    event VerifyTaskAttempt(
        address _user,
        uint16 _learningPathId,
        uint16 _taskId,
        uint64 _xpEarned,
        address _educator,
        uint256 timeInfo
    );

    /// @notice Raises an event to indicate that a task attempt by a user has been rejected by an educator
    /// @param _user The address of the user who attempted the task
    /// @param _learningPathId The id of the learning path the task belongs to
    /// @param _taskId The id of the task that was attempted
    /// @param _educator The address of the educator who rejected the task attempt
    /// @param timeInfo The time the task attempt was rejected
    event RejectTaskAttempt(
        address _user,
        uint16 _learningPathId,
        uint16 _taskId,
        address _educator,
        uint256 timeInfo
    );

    // Task Events

    /// @notice Raises an event to indicate that a new task has been created by an educator
    /// @param _educator The address of the educator who created the task
    /// @param _learningPathId The id of the learning path the task belongs to
    /// @param _taskId The id of the newly created task
    /// @param timeInfo The time the task was created
    event TaskCreated(
        address _educator,
        uint256 _learningPathId,
        uint256 _taskId,
        uint256 timeInfo
    );

    // Learning Path Events

    /// @notice Raises an event to indicate that a new learning path has been created by an educator
    /// @param _educator The address of the educator who created the learning path
    /// @param _id The id of the newly created learning path
    /// @param timeInfo The time the learning path was created
    event LearningPathCreated(
        address _educator,
        uint16 _id,
        uint256 timeInfo
    );

    /// @notice Event emitted when a learning path is activated by an educator
    /// @param _educator The address of the educator who activated the learning path
    /// @param _id The unique identifier of the learning path
    /// @param timeInfo Timestamp of the event
    event LearningPathActivated(
        address _educator,
        uint16 _id,
        uint256 timeInfo
    );

    /// @notice Event emitted when a learning path is inactivated by an educator
    /// @param _educator The address of the educator who inactivated the learning path
    /// @param _id The unique identifier of the learning path
    /// @param timeInfo Timestamp of the event
    event LearningPathInactivated(
        address _educator,
        uint16 _id,
        uint256 timeInfo
    );

    // Admin Events

    /// @notice Event emitted when a learning path is activated by an admin
    /// @param _educator The address of the educator who the learning path belongs to
    /// @param _id The unique identifier of the learning path
    /// @param timeInfo Timestamp of the event
    event AdminActivatedPath(
        address _educator,
        uint16 _id,
        uint256 timeInfo
    );

    /// @notice Event emitted when an admin inactivates a learning path
    /// @param _educator Address of the educator who created the learning path
    /// @param _id Identifier of the learning path
    /// @param timeInfo Timestamp of when the event was emitted
    event AdminInctivatedPath(
        address _educator,
        uint16 _id,
        uint256 timeInfo
    );

    /// @notice Event emitted when an admin verifies a task attempt
    /// @param _user Address of the user who attempted the task
    /// @param _learningPathId Identifier of the learning path containing the task
    /// @param _taskId Identifier of the task that was attempted
    /// @param _xpEarned Amount of XP earned for the task attempt
    /// @param _educator Address of the educator who verified the task attempt
    /// @param timeInfo Timestamp of when the event was emitted
    event AdminVerifyTaskAttempt(
        address _user,
        uint16 _learningPathId,
        uint16 _taskId,
        uint64 _xpEarned,
        address _educator,
        uint256 timeInfo
    );

    /// @notice Event emitted when an admin rejects a task attempt
    /// @param _user Address of the user who attempted the task
    /// @param _learningPathId Identifier of the learning path containing the task
    /// @param _taskId Identifier of the task that was attempted
    /// @param _educator Address of the educator who rejected the task attempt
    /// @param timeInfo Timestamp of when the event was emitted
    event AdminRejectTaskAttempt(
        address _user,
        uint16 _learningPathId,
        uint16 _taskId,
        address _educator,
        uint256 timeInfo
    );

    /// @notice Event emitted when an admin edits the XP of a user
    /// @param _user Address of the user whose XP was edited
    /// @param _xp The new XP value for the user
    /// @param timeInfo Timestamp of when the event was emitted
    event AdminEditedXp(
        address _user,
        uint64 _xp,
        uint256 timeInfo
    );

    //-------------------------- VARIABLES --------------------------

    address public owner;

    // User Variables

    struct User {
        uint64 xp;
        uint16 level;
        bool isSuspended;
        mapping(address => mapping(uint16 => mapping(uint16 => UserTaskStatus))) attemptedTasks;
    }

    enum UserTaskStatus{NotAttempted, InProgress, Rejected, Verified}

    mapping(address => User) public user;
    mapping(address => bool) public _isUser;
    mapping(address => bool) public deletedUser;
    address[] public userList;

    // Educator Variables

    struct Educator {
        string name;
        string communityName;
    }

    mapping(address => Educator) public educator;
    mapping(address => bool) public _isEducator;
    mapping(address => bool) public deletedEducator;
    mapping(string => bool) public onlyOneEducator; // Only one educator for each community
    mapping(address => mapping(uint16 => mapping(uint16 => bool))) _onceVerified;
    mapping(address => mapping(uint16 => mapping(uint16 => bool))) _onceRejected;

    // Task Variables

    struct Task {
        uint64 xp;
        string name;
        string[] tags;
        uint256 deadline;
        uint32 numberOfWinners;
        address[] attemptedUsers;
        address[] winnerUsers;
    }

    // Learning Path Variables

    struct LearningPath {
        string name;
        LearningPathStatus status;
        Task[] task;
    }

    enum LearningPathStatus {Inactive, Active, Draft}

    mapping(address => LearningPath[]) public learningPath;

    constructor() {
        owner = msg.sender;
        _isEducator[owner] = true;
    }

    //-------------------------- MODIFIERS --------------------------

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner reserved only");
        _;
    }

    // User Modifiers

    modifier isUser(address _user) {
        require(_isUser[_user], "The user couldn't found!");
        _;
    }

    modifier isUserSuspended(address _user) {
        require(!(user[_user].isSuspended), "The user suspended");
        _;
    }

    // Educator Modifiers

    modifier isEducator(address _educator) {
        require(_isEducator[_educator], "You're not educator!");
        _;
    }

    modifier onceVerified(
        address _educator,
        uint16 _learningPathId,
        uint16 _taskId
    )
    {
        require(
            !(_onceVerified[_educator][_learningPathId][_taskId]),
            "Task verified by educator before"
        );
        _;
    }

    modifier onceRejected(
        address _educator,
        uint16 _learningPathId,
        uint16 _taskId
    )
    {
        require(
            !(_onceRejected[_educator][_learningPathId][_taskId]),
            "Task rejected by educator before"
        );
        _;
    }

    // Task Modifiers

    modifier userAttempted(
        address _user, 
        address _educator, 
        uint16 _learningPathId,
        uint16 _taskId
    ){
        require(
            user[_user].attemptedTasks[_educator][_learningPathId][_taskId] == UserTaskStatus.InProgress, 
            "User didn't attempted this task"
        );
        _;
    }

    modifier deadlinePassed(
        address _educator, 
        uint16 _learningPathId,
        uint16 _taskId
    ){
        require(
            learningPath[_educator][_learningPathId].task[_taskId].deadline > 
            block.timestamp, 
            "Task deadline passed"
        );
        _;
    }

    modifier numberOfWinnersFull(
        address _educator, 
        uint16 _learningPathId,
        uint16 _taskId
    ){
        require(
            learningPath[_educator][_learningPathId].task[_taskId].numberOfWinners > 
            learningPath[_educator][_learningPathId].task[_taskId].winnerUsers.length, 
            "The number of winners has been reached."
        );
        _;
    }

    // Learning Path Modifiers


    modifier learningPathAvailable(address _educator, uint16 _id){
        require(
            learningPath[_educator][_id].status == LearningPathStatus.Active, 
            "The learning path couldn't found"
        );
        _;
    }

    modifier pathReadyToActivate(address _educator, uint16 _id){
        require(
            (learningPath[_educator][_id].status == LearningPathStatus.Draft) || 
            (learningPath[_educator][_id].status == LearningPathStatus.Inactive), 
            "The learning path is not ready to publish "
        );
        _;
    }

    //-------------------------- FUNCTIONS --------------------------

    // User Functions

    /**
     * @notice A user registers on the platform
     * 
     * @dev Only non-registered and non-deleted users can be registered.
     * @dev A "UserRegistered" event is emitted with the user's address and block timestamp.
     */
    function registerUser() external {
        require( 
            !( _isUser[msg.sender] ), 
            "The user already registered!" 
        );
        require( 
            !( deletedUser[msg.sender] ), 
            "The user's account has been deleted!" 
        );

        _isUser[msg.sender] = true;

        User storage newUser = user[msg.sender];
        newUser.level = 1;

        userList.push(msg.sender);

        emit UserRegistered(msg.sender, block.timestamp);
    }

    /**
     * @notice Attempt a task as a user
     * 
     * @dev Only registered users can attempt tasks.
     * @dev Only available learning paths can be attempted.
     * @dev Only tasks with not passed deadlines can be attempted.
     * @param _educator The address of the educator
     * @param _learningPathId The ID of the learning path
     * @param _taskId The ID of the task
     */
    function attemptTask(
        address _educator, 
        uint16 _learningPathId,
        uint16 _taskId
    ) 
        external 
        isUser(msg.sender) 
        learningPathAvailable(_educator, _learningPathId)
        deadlinePassed(_educator, _learningPathId, _taskId)
    {
        user[msg.sender].attemptedTasks[_educator][_learningPathId][_taskId] = UserTaskStatus.InProgress;
        learningPath[_educator][_learningPathId].task[_taskId].attemptedUsers.push(msg.sender);

        emit UserAttemptedTask(
            msg.sender, 
            _educator, 
            _learningPathId,
            _taskId, 
            block.timestamp
        );
    }


    /**
     * @notice Gets the status of an attempted task
     * 
     * @dev Only registered users can have their task statuses checked.
     * @dev Only available learning paths can have their task statuses checked.
     * @dev Only attempted tasks can have their statuses checked.
     * @param _user The address of the user
     * @param _educator The address of the educator
     * @param _learningPathId The ID of the learning path
     * @param _taskId The ID of the task
     * @return The status of the attempted task
     */
    function getAttemptedTaskStatus(
        address _user, 
        address _educator, 
        uint16 _learningPathId,
        uint16 _taskId
    ) 
        external 
        isUser(_user)
        learningPathAvailable(_educator, _learningPathId)
        userAttempted(_user, _educator, _learningPathId, _taskId) 
        view 
        returns(UserTaskStatus) 
    {
        return user[_user].attemptedTasks[_educator][_learningPathId][_taskId];
    }

    /**
     * @notice Returns the list of all users.
     * 
     * @return address[] memory List of all users.
     */
    function getUserList() external onlyOwner view returns(address[] memory) {
        return userList;
    }

    // Educator Functions

    /**
     * @notice Verifies the task attempted by a user.
     * 
     * @param _user Address of the user who attempted the task.
     * @param _learningPathId ID of the learning path.
     * @param _taskId ID of the task.
     */
    function verifyTask(
        address _user, 
        uint16 _learningPathId,
        uint16 _taskId
    ) 
        external 
        isEducator(msg.sender)
        isUser(_user)
        isUserSuspended(_user)
        learningPathAvailable(msg.sender, _learningPathId)
        userAttempted(_user, msg.sender, _learningPathId, _taskId)
        numberOfWinnersFull(msg.sender, _learningPathId, _taskId)
        onceVerified(msg.sender, _learningPathId, _taskId)
    {
        user[_user].attemptedTasks[msg.sender][_learningPathId][_taskId] = UserTaskStatus.Verified;
        user[_user].xp += learningPath[msg.sender][_learningPathId].task[_taskId].xp;

        learningPath[msg.sender][_learningPathId].task[_taskId].winnerUsers.push(_user);

        _onceVerified[msg.sender][_learningPathId][_taskId] = true;

        // Leveling system = 100*2^(level-1)
        // Level 1 = 100 xp
        // Level 2 = 200 xp
        // Level 3 = 400 xp
        if(user[_user].xp > 100*2**(user[_user].level - 1)){
            user[_user].level++;
        }

        emit VerifyTaskAttempt(
            _user, 
            _learningPathId,
            _taskId, 
            learningPath[msg.sender][_learningPathId].task[_taskId].xp, 
            msg.sender, 
            block.timestamp
        );
    }

    /**
     * @notice Rejects the task attempted by a user.
     * 
     * @param _user Address of the user who attempted the task.
     * @param _learningPathId ID of the learning path.
     * @param _taskId ID of the task.
    */
    function rejectTask(
        address _user, 
        uint16 _learningPathId,
        uint16 _taskId
    )
        external
        isEducator(msg.sender)
        isUser(_user)
        isUserSuspended(_user)
        learningPathAvailable(msg.sender, _learningPathId)
        userAttempted(_user, msg.sender, _learningPathId, _taskId)
        onceRejected(msg.sender, _learningPathId, _taskId)
    {
        user[_user].attemptedTasks[msg.sender][_learningPathId][_taskId] = UserTaskStatus.Rejected;

        _onceRejected[msg.sender][_learningPathId][_taskId] = true;

        emit RejectTaskAttempt(
            _user, 
            _learningPathId,
            _taskId, 
            msg.sender, 
            block.timestamp
        );
    }

    // Task Functions

    function createTask(
        uint64 _xp,
        string memory _name,
        string[] memory _tags,
        uint256 _deadline,
        uint32 _numberOfWinners
    ) 
        private 
        isEducator(msg.sender)
    {
        require(_xp != 0, "XP couldn't be 0");
        address[] memory emptyAddressList;

        if(_deadline == 0 && _numberOfWinners == 0){
            Task memory newTask = Task({
                xp: _xp,
                name: _name,
                tags: _tags,
                deadline: block.timestamp + 999999 days,
                numberOfWinners: 999999,
                attemptedUsers: emptyAddressList,
                winnerUsers: emptyAddressList
            });

            learningPath[msg.sender][learningPath[msg.sender].length - 1].task.push(newTask);
        }
        else if(_deadline == 0 && _numberOfWinners != 0){
            Task memory newTask = Task({
                xp: _xp,
                name: _name,
                tags: _tags,
                deadline: block.timestamp + 999999 days,
                numberOfWinners: _numberOfWinners,
                attemptedUsers: emptyAddressList,
                winnerUsers: emptyAddressList
            });

            learningPath[msg.sender][learningPath[msg.sender].length - 1].task.push(newTask);
        }
        else if(_deadline != 0 && _numberOfWinners == 0){
            Task memory newTask = Task({
                xp: _xp,
                name: _name,
                tags: _tags,
                deadline: block.timestamp + _deadline,
                numberOfWinners: 999999,
                attemptedUsers: emptyAddressList,
                winnerUsers: emptyAddressList
            });

            learningPath[msg.sender][learningPath[msg.sender].length - 1].task.push(newTask);
        }
        else {
            Task memory newTask = Task({
                xp: _xp,
                name: _name,
                tags: _tags,
                deadline: block.timestamp + _deadline,
                numberOfWinners: _numberOfWinners,
                attemptedUsers: emptyAddressList,
                winnerUsers: emptyAddressList
            });

            learningPath[msg.sender][learningPath[msg.sender].length - 1].task.push(newTask);
        }

        emit TaskCreated(
            msg.sender,
            learningPath[msg.sender].length - 1, 
            learningPath[msg.sender][learningPath[msg.sender].length - 1].task.length, 
            block.timestamp
        );
    }

    /**
     * @notice Retrieve task information by educator and task ID.
     *
     * @dev A struct directly returns in this function.
     *
     * @param _educator The address of the task creator.
     * @param _learningPathId The learning path ID the task belongs to.
     * @param _taskId The ID of the task.
     *
     * @return The task information including XP, name, tags, deadline, number of winners, attempted users and winner users.
     */
    function getTaskInfo(
        address _educator, 
        uint256 _learningPathId,
        uint256 _taskId
    )
        external
        view
        returns(Task memory)
    {
        return learningPath[_educator][_learningPathId].task[_taskId];
    }

    // Learning Path Functions

    /**
     * @dev Function to create a new learning path by an educator
     *
     * @param _learningPathName The name of the new learning path
     * @param _xp The XP reward for each task in the learning path
     * @param _taskName The name of each task in the learning path
     * @param _tags The tags associated with each task in the learning path
     * @param _deadline The deadline for each task in the learning path
     * @param _numberOfWinners The number of winners for each task in the learning path
     */
    function createLearningPath(
        string memory _learningPathName,
        uint64[] memory _xp,
        string[] memory _taskName,
        string[][] memory _tags,
        uint256[] memory _deadline,
        uint32[] memory _numberOfWinners
    )
        external
        isEducator(msg.sender)
    {
        // Create an empty array of tasks for the new learning path
        Task[] memory emptyTask;
        // Create a new instance of the LearningPath struct
        LearningPath memory newPath = LearningPath({
            name: _learningPathName,
            status: LearningPathStatus.Draft,
            task: emptyTask
        });

        // Add the new learning path to the list of learning paths
        learningPath[msg.sender].push(newPath);
        // Create a task for each entry in the input arrays
        for(uint i = 0; i < _xp.length; i++){
            createTask(
                _xp[i],
                _taskName[i],
                _tags[i],
                _deadline[i],
                _numberOfWinners[i]
            );
        }
    }

    /**
     * @notice Inactivate a learning path by educator.
     *
     * @param _id The ID of the learning path to be inactivated.
     */
    function inactivateLearningPath( uint16 _id ) 
        external 
        isEducator(msg.sender) 
        learningPathAvailable(msg.sender, _id)
    {
        learningPath[msg.sender][_id].status = LearningPathStatus.Inactive;

        emit LearningPathInactivated(msg.sender, _id, block.timestamp);
    }

    /**
     * @notice Activate a learning path by educator.
     *
     * @param _id The ID of the learning path to be activated.
     */
    function activateLearningPath( uint16 _id ) 
        external 
        isEducator(msg.sender) 
        pathReadyToActivate(msg.sender, _id) 
    {
        learningPath[msg.sender][_id].status = LearningPathStatus.Inactive;

        emit LearningPathActivated(msg.sender, _id, block.timestamp);
    }

    // Admin Functions

    /**
     * @notice Function to delete a user from the platform
     *
     * @param _user address of the user to be deleted
     */
    function deleteUser( address _user ) external onlyOwner {
        for ( uint i = 0; i < userList.length; i++ ){
            if( userList[i] == _user ){
                delete userList[i];
                delete user[_user];
                _isUser[_user] = false;
                deletedUser[_user] = true;
                break;
            }
        }

        emit UserDeleted(_user, block.timestamp);
    }

    /**
     * @notice Function to suspend a user from the platform
     *
     * @param _user address of the user to be suspended
     */
    function suspendUser( address _user ) 
        external 
        onlyOwner 
        isUser(_user)
        isUserSuspended(_user) 
    {
        user[_user].isSuspended = true;

        emit UserSuspended(_user, block.timestamp);
    }

    /**
     * @notice Function to unsuspend a user from the platform
     *
     * @param _user address of the user to be unsuspended
     */
    function unsuspendUser( address _user ) 
        external 
        onlyOwner 
        isUser(_user) 
    {
        user[_user].isSuspended = false;

        emit UserUnsuspended(_user, block.timestamp);
    }

    /**
     * @notice Function to add a new educator to the platform
     *
     * @param _educator address of the educator to be added
     * @param _name name of the educator
     * @param _communityName community name of the educator
     */
    function addEducator( 
        address _educator, 
        string memory _name, 
        string memory _communityName 
    ) 
        external 
        onlyOwner 
    {
        require( 
            !(_isEducator[msg.sender]), 
            "The educator already added!" 
        );
        require( 
            !(deletedEducator[msg.sender]), 
            "The educator's account has been deleted!" 
        );
        require( 
            !(onlyOneEducator[_communityName]), 
            "This community has a educator!" 
        );
        require(
            !(_isUser[msg.sender]),
            "The educator can't registered as a user before"
        );

        _isEducator[_educator] = true;

        Educator memory newEducator = Educator({
            name: _name,
            communityName: _communityName
        });

        educator[_educator] = newEducator;
        onlyOneEducator[_communityName] = true;

        emit EducatorAdded(_educator, block.timestamp);
    }

    /**
     * @notice Function to add a new educator to the platform
     *
     * @param _educator address of the educator to be deleted
     */
    function deleteEducator( address _educator ) external onlyOwner {
        delete educator[_educator];
        _isEducator[_educator] = false;

        onlyOneEducator[educator[_educator].communityName] = false;

        emit EducatorDeleted(_educator, block.timestamp);
    }

    /**
     * @notice Inactivates a learning path.
     * 
     * @param _educator The address of the educator who created the learning path.
     * @param _id The id of the learning path.
     */
    function adminInactivatePath(address _educator, uint16 _id) external onlyOwner
    {
        learningPath[_educator][_id].status = LearningPathStatus.Inactive;

        emit AdminInctivatedPath(_educator, _id, block.timestamp);
    }

    /**
     * @notice Activates a learning path.
     *
     * @param _educator The address of the educator who created the learning path.
     * @param _id The id of the learning path.
     */
    function adminActivatePath(address _educator, uint16 _id) external onlyOwner
    {
        learningPath[_educator][_id].status = LearningPathStatus.Active;

        emit AdminActivatedPath(_educator, _id, block.timestamp);
    }

    /**
     * @notice Verifies a task attempt by a user.
     * 
     * @param _user The address of the user who attempted the task.
     * @param _educator The address of the educator who created the learning path.
     * @param _learningPathId The id of the learning path.
     * @param _taskId The id of the task.
     */
    function adminVerifyTask(
        address _user,
        address _educator, 
        uint16 _learningPathId,
        uint16 _taskId
    ) 
        external 
        isEducator(_educator)
        isUser(_user)
        isUserSuspended(_user)
        learningPathAvailable(_educator, _learningPathId)
        userAttempted(_user, _educator, _learningPathId, _taskId)
        numberOfWinnersFull(_educator, _learningPathId, _taskId)
        onlyOwner
    {
        user[_user].attemptedTasks[_educator][_learningPathId][_taskId] = UserTaskStatus.Verified;
        user[_user].xp += learningPath[_educator][_learningPathId].task[_taskId].xp;

        learningPath[_educator][_learningPathId].task[_taskId].winnerUsers.push(_user);

        emit AdminVerifyTaskAttempt(
            _user, 
            _learningPathId,
            _taskId, 
            learningPath[msg.sender][_learningPathId].task[_taskId].xp, 
            _educator, 
            block.timestamp
        );
    }

    /**
     * @notice Rejects a task attempt by a user.
     * 
     * @param _user The address of the user who attempted the task.
     * @param _educator The address of the educator who created the learning path.
     * @param _learningPathId The id of the learning path.
     * @param _taskId The id of the task.
     */
    function adminRejectTask(
        address _user,
        address _educator, 
        uint16 _learningPathId,
        uint16 _taskId
    )
        external
        isEducator(_educator)
        isUser(_user)
        isUserSuspended(_user)
        learningPathAvailable(_educator, _learningPathId)
        userAttempted(_user, _educator, _learningPathId, _taskId)
        onlyOwner
    {
        user[_user].attemptedTasks[_educator][_learningPathId][_taskId] = UserTaskStatus.Rejected;

        emit AdminRejectTaskAttempt(
            _user, 
            _learningPathId,
            _taskId, 
            _educator, 
            block.timestamp
        );
    }

    /**
     * @notice Function to edit the XP of a user by an admin
     *
     * @param _user Address of the user whose XP is to be edited
     * @param _xp The new XP value for the user
     */
    function adminEditXp(address _user, uint64 _xp) external onlyOwner {
        user[_user].xp = _xp;

        emit AdminEditedXp(_user, _xp, block.timestamp);
    }

    function shutdown() external onlyOwner {
        selfdestruct(payable(owner));
    }
    
    function withdraw() external payable onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    fallback() external payable {}
}