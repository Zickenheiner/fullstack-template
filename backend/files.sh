#!/bin/bash

# Verify input
if [ $# -ne 2 ]; then
    echo "Usage: $0 <file-name> <feature-name>"
    exit 1
fi

# Get the file name
FILE_NAME=$1
FILE_NAME_LOWER=$(echo $FILE_NAME | tr '[:upper:]' '[:lower:]')
FILE_NAME_PASCAL=$(echo $FILE_NAME | perl -pe 's/\b([a-z])/\u$1/g')

# Get the feature name
FEATURE_NAME=$2
FEATURE_NAME_LOWER=$(echo $FEATURE_NAME | tr '[:upper:]' '[:lower:]')

# Define the base path for the feature
BASE_PATH="src/features/$FEATURE_NAME_LOWER"

# If the base path doesn't exist, create the feature
if [ ! -d "$BASE_PATH" ]; then
  ./feature.sh $FEATURE_NAME_LOWER
fi

# Create files
touch "$BASE_PATH/domains/entities/$FILE_NAME_LOWER.entity.ts"
touch "$BASE_PATH/domains/dtos/$FILE_NAME_LOWER.dto.ts"
touch "$BASE_PATH/domains/schemas/$FILE_NAME_LOWER.schema.ts"
touch "$BASE_PATH/interfaces/services/$FILE_NAME_LOWER.iservice.ts"
touch "$BASE_PATH/interfaces/repositories/$FILE_NAME_LOWER.irepository.ts"
touch "$BASE_PATH/modules/controllers/$FILE_NAME_LOWER.controller.ts"
touch "$BASE_PATH/modules/implementation/services/$FILE_NAME_LOWER.service.ts"
touch "$BASE_PATH/modules/implementation/repositories/$FILE_NAME_LOWER.repository.ts"
touch "$BASE_PATH/modules/implementation/mappers/$FILE_NAME_LOWER.mapper.ts"
touch "$BASE_PATH/modules/$FILE_NAME_LOWER.module.ts"

# Generate base content for each file
echo "import { ApiProperty } from '@nestjs/swagger';
import { ${FILE_NAME_PASCAL} } from '../schemas/${FILE_NAME_LOWER}.schema';

export class ${FILE_NAME_PASCAL}Entity {
  @ApiProperty({
    example: '68b4d59919d9b7a94b4fde21',
    description: 'The unique identifier of the ${FILE_NAME_LOWER}',
  })
  private readonly id: ${FILE_NAME_PASCAL};

  constructor(_id: ${FILE_NAME_PASCAL}) {
    this.id = _id;
  }

  // ———————GETTER———————

  getId(): string {
    return this.id.toString();
  }

  getObjectId(): ${FILE_NAME_PASCAL} {
    return this.id;
  }

  //———————SETTER———————
}" > "$BASE_PATH/domains/entities/$FILE_NAME_LOWER.entity.ts"

echo "export class Create${FILE_NAME_PASCAL}Dto {}

export class Update${FILE_NAME_PASCAL}Dto {}" > "$BASE_PATH/domains/dtos/$FILE_NAME_LOWER.dto.ts"

echo "import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';

export type ${FILE_NAME_PASCAL}Document = ${FILE_NAME_PASCAL} & Document;

@Schema({ timestamps: true })
export class ${FILE_NAME_PASCAL} {
  @Prop({ type: mongoose.Schema.Types.ObjectId, auto: true })
  _id: ${FILE_NAME_PASCAL};
}

export const ${FILE_NAME_PASCAL}Schema = SchemaFactory.createForClass(${FILE_NAME_PASCAL});" > "$BASE_PATH/domains/schemas/$FILE_NAME_LOWER.schema.ts"

echo "import { Create${FILE_NAME_PASCAL}Dto, Update${FILE_NAME_PASCAL}Dto } from '@features/${FEATURE_NAME_LOWER}/domains/dtos/${FILE_NAME_LOWER}.dto';
import { ${FILE_NAME_PASCAL}Entity } from '@features/${FEATURE_NAME_LOWER}/domains/entities/${FILE_NAME_LOWER}.entity';

export interface I${FILE_NAME_PASCAL}Repository {
  findAll(): Promise<${FILE_NAME_PASCAL}Entity[] | null>;
  findById(id: string): Promise<${FILE_NAME_PASCAL}Entity | null>;
  create(dto: Create${FILE_NAME_PASCAL}Dto): Promise<boolean>;
  update(id: string, dto: Update${FILE_NAME_PASCAL}Dto): Promise<boolean>;
  delete(id: string): Promise<boolean>;
}" > "$BASE_PATH/interfaces/repositories/$FILE_NAME_LOWER.irepository.ts"

echo "import { Create${FILE_NAME_PASCAL}Dto, Update${FILE_NAME_PASCAL}Dto } from '@features/${FEATURE_NAME_LOWER}/domains/dtos/${FILE_NAME_LOWER}.dto';
import { ${FILE_NAME_PASCAL}Entity } from '@features/${FEATURE_NAME_LOWER}/domains/entities/${FILE_NAME_LOWER}.entity';

export interface I${FILE_NAME_PASCAL}Service {
  findAll(): Promise<${FILE_NAME_PASCAL}Entity[] | null>;
  findById(id: string): Promise<${FILE_NAME_PASCAL}Entity | null>;
  create(dto: Create${FILE_NAME_PASCAL}Dto): Promise<boolean>;
  update(id: string, dto: Update${FILE_NAME_PASCAL}Dto): Promise<boolean>;
  delete(id: string): Promise<boolean>;
}" > "$BASE_PATH/interfaces/services/$FILE_NAME_LOWER.iservice.ts"

echo "import { ${FILE_NAME_PASCAL}Entity } from '@features/${FEATURE_NAME_LOWER}/domains/entities/${FILE_NAME_LOWER}.entity';
import { ${FILE_NAME_PASCAL}Document } from '@features/${FEATURE_NAME_LOWER}/domains/schemas/${FILE_NAME_LOWER}.schema';
import { Injectable } from '@nestjs/common';

@Injectable()
export class ${FILE_NAME_PASCAL}Mapper {
  toEntity(doc: ${FILE_NAME_PASCAL}Document): ${FILE_NAME_PASCAL}Entity {
    return new ${FILE_NAME_PASCAL}Entity(doc._id);
  }
}" > "$BASE_PATH/modules/implementation/mappers/$FILE_NAME_LOWER.mapper.ts"

echo "import { Injectable } from '@nestjs/common';
import { I${FILE_NAME_PASCAL}Repository } from '../../../interfaces/repositories/${FILE_NAME_LOWER}.irepository';
import { ${FILE_NAME_PASCAL}Mapper } from '../mappers/${FILE_NAME_LOWER}.mapper';
import { ${FILE_NAME_PASCAL}, ${FILE_NAME_PASCAL}Document } from '@features/${FEATURE_NAME_LOWER}/domains/schemas/${FILE_NAME_LOWER}.schema';
import { Model } from 'mongoose';
import { Create${FILE_NAME_PASCAL}Dto, Update${FILE_NAME_PASCAL}Dto } from '@features/${FEATURE_NAME_LOWER}/domains/dtos/${FILE_NAME_LOWER}.dto';
import { ${FILE_NAME_PASCAL}Entity } from '@features/${FEATURE_NAME_LOWER}/domains/entities/${FILE_NAME_LOWER}.entity';
import { InjectModel } from '@nestjs/mongoose';

@Injectable()
export class ${FILE_NAME_PASCAL}Repository implements I${FILE_NAME_PASCAL}Repository {
  constructor(
    @InjectModel(${FILE_NAME_PASCAL}.name)
    private readonly ${FILE_NAME_LOWER}Model: Model<${FILE_NAME_PASCAL}Document>,
    private readonly ${FILE_NAME_LOWER}Mapper: ${FILE_NAME_PASCAL}Mapper,
  ) {}

  async findAll(): Promise<${FILE_NAME_PASCAL}Entity[] | null> {
    const ${FILE_NAME_LOWER}s = await this.${FILE_NAME_LOWER}Model.find().exec();
    return ${FILE_NAME_LOWER}s ? ${FILE_NAME_LOWER}s.map(this.${FILE_NAME_LOWER}Mapper.toEntity) : null;
  }

  async findById(id: string): Promise<${FILE_NAME_PASCAL}Entity | null> {
    const ${FILE_NAME_LOWER} = await this.${FILE_NAME_LOWER}Model.findById(id).exec();
    return ${FILE_NAME_LOWER} ? this.${FILE_NAME_LOWER}Mapper.toEntity(${FILE_NAME_LOWER}) : null;
  }

  async create(dto: Create${FILE_NAME_PASCAL}Dto): Promise<boolean> {
    const document = new this.${FILE_NAME_LOWER}Model(dto);
    const created${FILE_NAME_PASCAL} = await document.save();
    return !!created${FILE_NAME_PASCAL};
  }

  async update(id: string, dto: Update${FILE_NAME_PASCAL}Dto): Promise<boolean> {
    const updated${FILE_NAME_PASCAL} = await this.${FILE_NAME_LOWER}Model
      .findByIdAndUpdate(id, dto, { new: true })
      .exec();
    return !!updated${FILE_NAME_PASCAL};
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.${FILE_NAME_LOWER}Model.findByIdAndDelete(id).exec();
    return !!result;
  }
}" > "$BASE_PATH/modules/implementation/repositories/$FILE_NAME_LOWER.repository.ts"

echo "import { Inject, Injectable } from '@nestjs/common';
import { I${FILE_NAME_PASCAL}Service } from '../../../interfaces/services/${FILE_NAME_LOWER}.iservice';
import { I${FILE_NAME_PASCAL}Repository } from '@features/${FEATURE_NAME_LOWER}/interfaces/repositories/${FILE_NAME_LOWER}.irepository';
import { Create${FILE_NAME_PASCAL}Dto, Update${FILE_NAME_PASCAL}Dto } from '@features/${FEATURE_NAME_LOWER}/domains/dtos/${FILE_NAME_LOWER}.dto';
import { ${FILE_NAME_PASCAL}Entity } from '@features/${FEATURE_NAME_LOWER}/domains/entities/${FILE_NAME_LOWER}.entity';

@Injectable()
export class ${FILE_NAME_PASCAL}Service implements I${FILE_NAME_PASCAL}Service {
  constructor(
    @Inject('I${FILE_NAME_PASCAL}Repository')
    private readonly ${FILE_NAME_LOWER}Repository: I${FILE_NAME_PASCAL}Repository,
  ) {}

  async findAll(): Promise<${FILE_NAME_PASCAL}Entity[] | null> {
    return this.${FILE_NAME_LOWER}Repository.findAll();
  }

  async findById(id: string): Promise<${FILE_NAME_PASCAL}Entity | null> {
    return this.${FILE_NAME_LOWER}Repository.findById(id);
  }

  async create(dto: Create${FILE_NAME_PASCAL}Dto): Promise<boolean> {
    return this.${FILE_NAME_LOWER}Repository.create(dto);
  }

  async update(id: string, dto: Update${FILE_NAME_PASCAL}Dto): Promise<boolean> {
    return this.${FILE_NAME_LOWER}Repository.update(id, dto);
  }

  async delete(id: string): Promise<boolean> {
    return this.${FILE_NAME_LOWER}Repository.delete(id);
  }
}" > "$BASE_PATH/modules/implementation/services/$FILE_NAME_LOWER.service.ts"

echo "import { Create${FILE_NAME_PASCAL}Dto, Update${FILE_NAME_PASCAL}Dto } from '@features/${FEATURE_NAME_LOWER}/domains/dtos/${FILE_NAME_LOWER}.dto';
import { ${FILE_NAME_PASCAL}Entity } from '@features/${FEATURE_NAME_LOWER}/domains/entities/${FILE_NAME_LOWER}.entity';
import { I${FILE_NAME_PASCAL}Service } from '@features/${FEATURE_NAME_LOWER}/interfaces/services/${FILE_NAME_LOWER}.iservice';
import {
  Body,
  Controller,
  Delete,
  Get,
  Inject,
  Param,
  Post,
  Patch,
} from '@nestjs/common';
import { ApiBody, ApiOperation, ApiParam, ApiResponse } from '@nestjs/swagger';

@Controller('${FILE_NAME_LOWER}')
export class ${FILE_NAME_PASCAL}Controller {
  constructor(
    @Inject('I${FILE_NAME_PASCAL}Service')
    private readonly ${FILE_NAME_LOWER}Service: I${FILE_NAME_PASCAL}Service,
  ) {}

  @ApiOperation({
    summary: 'Get all ${FILE_NAME_LOWER}s',
    description: 'Retrieve a list of all ${FILE_NAME_LOWER}s',
  })
  @ApiResponse({
    status: 200,
    description: 'List of all ${FILE_NAME_LOWER}s',
    type: [${FILE_NAME_PASCAL}Entity],
  })
  @Get()
  async findAll() {
    return this.${FILE_NAME_LOWER}Service.findAll();
  }

  @ApiOperation({
    summary: 'Get ${FILE_NAME_LOWER} by id',
    description: 'Retrieve a ${FILE_NAME_LOWER} by its id',
  })
  @ApiParam({
    name: 'id',
    description: 'The id of the ${FILE_NAME_LOWER} to retrieve',
    required: true,
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'The ${FILE_NAME_LOWER} with the given id',
    type: ${FILE_NAME_PASCAL}Entity,
  })
  @Get(':id')
  async findById(@Param('id') id: string) {
    return this.${FILE_NAME_LOWER}Service.findById(id);
  }

  @ApiOperation({
    summary: 'Create ${FILE_NAME_LOWER}',
    description: 'Create a new ${FILE_NAME_LOWER}',
  })
  @ApiBody({
    type: Create${FILE_NAME_PASCAL}Dto,
    description: 'The data to create a new ${FILE_NAME_LOWER}',
    required: true,
  })
  @ApiResponse({
    status: 201,
    description: 'The created ${FILE_NAME_LOWER}',
    type: Boolean,
  })
  @Post()
  async create(@Body() dto: Create${FILE_NAME_PASCAL}Dto) {
    return this.${FILE_NAME_LOWER}Service.create(dto);
  }

  @ApiOperation({
    summary: 'Update ${FILE_NAME_LOWER}',
    description: 'Update a ${FILE_NAME_LOWER}',
  })
  @ApiParam({
    name: 'id',
    description: 'The id of the ${FILE_NAME_LOWER} to update',
    required: true,
    type: String,
  })
  @ApiBody({
    type: Update${FILE_NAME_PASCAL}Dto,
    description: 'The updated ${FILE_NAME_LOWER} data',
    required: true,
  })
  @ApiResponse({
    status: 200,
    description: 'The updated ${FILE_NAME_LOWER}',
    type: Boolean,
  })
  @Patch(':id')
  async update(@Param('id') id: string, @Body() dto: Update${FILE_NAME_PASCAL}Dto) {
    return this.${FILE_NAME_LOWER}Service.update(id, dto);
  }

  @ApiOperation({
    summary: 'Delete ${FILE_NAME_LOWER}',
    description: 'Delete a ${FILE_NAME_LOWER}',
  })
  @ApiParam({
    name: 'id',
    description: 'The id of the ${FILE_NAME_LOWER} to delete',
    required: true,
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'The deleted ${FILE_NAME_LOWER}',
    type: Boolean,
  })
  @Delete(':id')
  async delete(@Param('id') id: string) {
    return this.${FILE_NAME_LOWER}Service.delete(id);
  }
}" > "$BASE_PATH/modules/controllers/$FILE_NAME_LOWER.controller.ts"

echo "import { Module } from '@nestjs/common';
import { ${FILE_NAME_PASCAL}Controller } from './controllers/${FILE_NAME_LOWER}.controller';
import { ${FILE_NAME_PASCAL}Service } from './implementation/services/${FILE_NAME_LOWER}.service';
import { ${FILE_NAME_PASCAL}Repository } from './implementation/repositories/${FILE_NAME_LOWER}.repository';
import { ${FILE_NAME_PASCAL}Mapper } from './implementation/mappers/${FILE_NAME_LOWER}.mapper';
import { ${FILE_NAME_PASCAL}, ${FILE_NAME_PASCAL}Schema } from '@features/${FEATURE_NAME_LOWER}/domains/schemas/${FILE_NAME_LOWER}.schema';
import { MongooseModule } from '@nestjs/mongoose';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: ${FILE_NAME_PASCAL}.name, schema: ${FILE_NAME_PASCAL}Schema }])
  ],
  controllers: [${FILE_NAME_PASCAL}Controller],
  providers: [
    ${FILE_NAME_PASCAL}Mapper,
    {
      provide: 'I${FILE_NAME_PASCAL}Service',
      useClass: ${FILE_NAME_PASCAL}Service,
    },
    {
      provide: 'I${FILE_NAME_PASCAL}Repository',
      useClass: ${FILE_NAME_PASCAL}Repository,
    },
  ],
  exports: ['I${FILE_NAME_PASCAL}Service'],
})
export class ${FILE_NAME_PASCAL}BaseModule {}" > "$BASE_PATH/modules/$FILE_NAME_LOWER.module.ts"

echo "Files created successfully: $FILE_NAME_PASCAL"