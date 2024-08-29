class_name ThreadManager

var threads: Array[Thread]
var outputs: Array[Array]
var background_thread := Thread.new()

func _init(number:int):
	for i in range(number):
		threads.append(Thread.new())
		outputs.append([])


## Function to execute a command in a specific thread
func execute(index: int, exec_path: String, exec_args: Array):
	print("[INFO] Creating processes for threads")
	if index >= threads.size():
		print("[WARNING] trying to execute with an index superior to the number of threads")
		return
	var thread: Thread = threads[index]

	var exec_func = func() -> void:
		OS.execute(exec_path, exec_args, outputs[index], true, true)

	thread.start(exec_func)

## A function do print all outputs
func dump_outputs() -> Thread:
	var dump = func() -> void:
		for thread in threads:
			thread.wait_to_finish()
		print("[INFO] dumping outputs")
		for out in outputs:
			print("".join(out))
	background_thread.start(dump)
	return background_thread
