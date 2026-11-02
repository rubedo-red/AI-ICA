extends CharacterBody3D

enum Pathfinding_Algorithm { DFS, BFS, DIJKSTRA, ASTAR }

@export var active_algorithm: Pathfinding_Algorithm = Pathfinding_Algorithm.DFS


func run_dfs(grid: PathfindingGrid3D) -> bool:
	return false


func run_bfs(grid: PathfindingGrid3D) -> bool:
	return false


func run_dijkstra(grid: PathfindingGrid3D) -> bool:
	return false


func run_astar(grid: PathfindingGrid3D) -> bool:
	return false
