�G
��
8
Const
output"dtype"
valuetensor"
dtypetype

NoOp
�
PartitionedCall
args2Tin
output2Tout"
Tin
list(type)("
Tout
list(type)("	
ffunc"
configstring "
config_protostring "
executor_typestring 
C
Placeholder
output"dtype"
dtypetype"
shapeshape:
�
StatefulPartitionedCall
args2Tin
output2Tout"
Tin
list(type)("
Tout
list(type)("	
ffunc"
configstring "
config_protostring "
executor_typestring �"serve*	2.2.0-rc02v2.2.0-rc0-0-g3c1e8c03418�<

NoOpNoOp
i
ConstConst"/device:CPU:0*
_output_shapes
: *
dtype0*%
valueB B


signatures
 
R
serving_default_aPlaceholder*
_output_shapes
: *
dtype0*
shape: 
R
serving_default_bPlaceholder*
_output_shapes
: *
dtype0*
shape: 
�
PartitionedCallPartitionedCallserving_default_aserving_default_b*
Tin
2*
Tout
2*
_output_shapes
: * 
_read_only_resource_inputs
 **
config_proto

GPU 

CPU2J 8*)
f$R"
 __inference_signature_wrapper_46
O
saver_filenamePlaceholder*
_output_shapes
: *
dtype0*
shape: 
�
StatefulPartitionedCallStatefulPartitionedCallsaver_filenameConst*
Tin
2*
Tout
2*
_output_shapes
: * 
_read_only_resource_inputs
 **
config_proto

GPU 

CPU2J 8*$
fR
__inference__traced_save_70
�
StatefulPartitionedCall_1StatefulPartitionedCallsaver_filename*
Tin
2*
Tout
2*
_output_shapes
: * 
_read_only_resource_inputs
 **
config_proto

GPU 

CPU2J 8*'
f"R 
__inference__traced_restore_80�3
�
v
while_cond_9
while_loop_counter
while_maximum_iterations
placeholder
placeholder_1
identity
X
	Greater/yConst*
_output_shapes
: *
dtype0*
value	B : 2
	Greater/y_
GreaterGreaterplaceholderGreater/y:output:0*
T0*
_output_shapes
: 2	
GreaterN
IdentityIdentityGreater:z:0*
T0
*
_output_shapes
: 2

Identity"
identityIdentity:output:0*
_input_shapes

: : : : : 

_output_shapes
: :

_output_shapes
: :

_output_shapes
: :

_output_shapes
: 
�
�
while_body_10
while_loop_counter
while_maximum_iterations
placeholder
placeholder_1
identity

identity_1

identity_2

identity_3S
modFloorModplaceholder_1placeholder*
T0*
_output_shapes
: 2
modP
add/yConst*
_output_shapes
: *
dtype0*
value	B :2
add/yX
addAddV2while_loop_counteradd/y:output:0*
T0*
_output_shapes
: 2
addJ
IdentityIdentityadd:z:0*
T0*
_output_shapes
: 2

Identity_

Identity_1Identitywhile_maximum_iterations*
T0*
_output_shapes
: 2

Identity_1N

Identity_2Identitymod:z:0*
T0*
_output_shapes
: 2

Identity_2R

Identity_3Identityplaceholder*
T0*
_output_shapes
: 2

Identity_3"
identityIdentity:output:0"!

identity_1Identity_1:output:0"!

identity_2Identity_2:output:0"!

identity_3Identity_3:output:0*
_input_shapes

: : : : : 

_output_shapes
: :

_output_shapes
: :

_output_shapes
: :

_output_shapes
: 
�
q
__inference__traced_save_70
file_prefix
savev2_const

identity_1��MergeV2Checkpoints�SaveV2�
StaticRegexFullMatchStaticRegexFullMatchfile_prefix"/device:CPU:**
_output_shapes
: *
pattern
^s3://.*2
StaticRegexFullMatchc
ConstConst"/device:CPU:**
_output_shapes
: *
dtype0*
valueB B.part2
Const�
Const_1Const"/device:CPU:**
_output_shapes
: *
dtype0*<
value3B1 B+_temp_7f0a7eb865a044f384a243901e9f9208/part2	
Const_1�
SelectSelectStaticRegexFullMatch:output:0Const:output:0Const_1:output:0"/device:CPU:**
T0*
_output_shapes
: 2
Selectt

StringJoin
StringJoinfile_prefixSelect:output:0"/device:CPU:**
N*
_output_shapes
: 2

StringJoinZ

num_shardsConst*
_output_shapes
: *
dtype0*
value	B :2

num_shards
ShardedFilename/shardConst"/device:CPU:0*
_output_shapes
: *
dtype0*
value	B : 2
ShardedFilename/shard�
ShardedFilenameShardedFilenameStringJoin:output:0ShardedFilename/shard:output:0num_shards:output:0"/device:CPU:0*
_output_shapes
: 2
ShardedFilename�
SaveV2/tensor_namesConst"/device:CPU:0*
_output_shapes
:*
dtype0*1
value(B&B_CHECKPOINTABLE_OBJECT_GRAPH2
SaveV2/tensor_names�
SaveV2/shape_and_slicesConst"/device:CPU:0*
_output_shapes
:*
dtype0*
valueB
B 2
SaveV2/shape_and_slices�
SaveV2SaveV2ShardedFilename:filename:0SaveV2/tensor_names:output:0 SaveV2/shape_and_slices:output:0savev2_const"/device:CPU:0*
_output_shapes
 *
dtypes
22
SaveV2�
&MergeV2Checkpoints/checkpoint_prefixesPackShardedFilename:filename:0^SaveV2"/device:CPU:0*
N*
T0*
_output_shapes
:2(
&MergeV2Checkpoints/checkpoint_prefixes�
MergeV2CheckpointsMergeV2Checkpoints/MergeV2Checkpoints/checkpoint_prefixes:output:0file_prefix^SaveV2"/device:CPU:0*
_output_shapes
 2
MergeV2Checkpointsr
IdentityIdentityfile_prefix^MergeV2Checkpoints"/device:CPU:0*
T0*
_output_shapes
: 2

Identityv

Identity_1IdentityIdentity:output:0^MergeV2Checkpoints^SaveV2*
T0*
_output_shapes
: 2

Identity_1"!

identity_1Identity_1:output:0*
_input_shapes
: : 2(
MergeV2CheckpointsMergeV2Checkpoints2
SaveV2SaveV2:C ?

_output_shapes
: 
%
_user_specified_namefile_prefix:

_output_shapes
: 
�
P
__inference__traced_restore_80
file_prefix

identity_1��	RestoreV2�
RestoreV2/tensor_namesConst"/device:CPU:0*
_output_shapes
:*
dtype0*1
value(B&B_CHECKPOINTABLE_OBJECT_GRAPH2
RestoreV2/tensor_names�
RestoreV2/shape_and_slicesConst"/device:CPU:0*
_output_shapes
:*
dtype0*
valueB
B 2
RestoreV2/shape_and_slices�
	RestoreV2	RestoreV2file_prefixRestoreV2/tensor_names:output:0#RestoreV2/shape_and_slices:output:0"/device:CPU:0*
_output_shapes
:*
dtypes
22
	RestoreV29
NoOpNoOp"/device:CPU:0*
_output_shapes
 2
NoOpd
IdentityIdentityfile_prefix^NoOp"/device:CPU:0*
T0*
_output_shapes
: 2

Identityd

Identity_1IdentityIdentity:output:0
^RestoreV2*
T0*
_output_shapes
: 2

Identity_1"!

identity_1Identity_1:output:0*
_input_shapes
: 2
	RestoreV2	RestoreV2:C ?

_output_shapes
: 
%
_user_specified_namefile_prefix
�
>
 __inference_signature_wrapper_46
a
b
identity�
PartitionedCallPartitionedCallab*
Tin
2*
Tout
2*
_XlaMustCompile(*
_output_shapes
: * 
_read_only_resource_inputs
 **
config_proto

GPU 

CPU2J 8*
fR
__inference_gcd_382
PartitionedCall[
IdentityIdentityPartitionedCall:output:0*
T0*
_output_shapes
: 2

Identity"
identityIdentity:output:0*
_input_shapes
: : :9 5

_output_shapes
: 

_user_specified_namea:95

_output_shapes
: 

_user_specified_nameb
�
0
__inference_gcd_38
a
b
identity
while/maximum_iterationsConst*
_output_shapes
: *
dtype0*
valueB :
���������2
while/maximum_iterationsj
while/loop_counterConst*
_output_shapes
: *
dtype0*
value	B : 2
while/loop_counter�
whileStatelessWhilewhile/loop_counter:output:0!while/maximum_iterations:output:0ba*
T
2*
_lower_using_switch_merge(*
_num_original_outputs*
_output_shapes

: : : : * 
_read_only_resource_inputs
 *
bodyR
while_body_10*
condR
while_cond_9*
output_shapes

: : : : 2
whileQ
IdentityIdentitywhile:output:3*
T0*
_output_shapes
: 2

Identity"
identityIdentity:output:0*
_XlaMustCompile(*
_input_shapes
: : *
	_noinline(:9 5

_output_shapes
: 

_user_specified_namea:95

_output_shapes
: 

_user_specified_nameb"�J
saver_filename:0StatefulPartitionedCall:0StatefulPartitionedCall_18"
saved_model_main_op

NoOp*>
__saved_model_init_op%#
__saved_model_init_op

NoOp*�
serving_default�

a
serving_default_a:0 

b
serving_default_b:0 #
output_0
PartitionedCall:0 tensorflow/serving/predict:�
7

signatures
gcd"
_generic_user_object
,
serving_default"
signature_map
�2�
__inference_gcd_38�
���
FullArgSpec
args�

ja
jb
varargs
 
varkw
 
defaults
 

kwonlyargs� 
kwonlydefaults
 
annotations� *�
� 
� 
*B(
 __inference_signature_wrapper_46abF
__inference_gcd_380%�"
�

�
a 

�
b 
� "� y
 __inference_signature_wrapper_46U/�,
� 
%�"

a
�
a 

b
�
b ""�

output_0�
output_0 