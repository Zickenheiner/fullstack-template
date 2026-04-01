#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Usage: $0 <file-name> <feature-name>"
    exit 1
fi

FILE_NAME=$1
FILE_NAME_LOWER=$(echo $FILE_NAME | tr '[:upper:]' '[:lower:]')
FILE_NAME_PASCALE=$(echo $FILE_NAME | perl -pe 's/\b([a-z])/\u$1/g')

FEATURE_NAME=$2
FEATURE_NAME_LOWER=$(echo $FEATURE_NAME | tr '[:upper:]' '[:lower:]')

BASE_PATH="src/features/$FEATURE_NAME_LOWER"

if [ ! -d "$BASE_PATH" ]; then
  ./feature.sh $FEATURE_NAME
fi

# Create the files
touch $BASE_PATH/data/datasources/${FILE_NAME_LOWER}.api.ts
touch $BASE_PATH/data/repositories/${FILE_NAME_LOWER}.repository.impl.ts
touch $BASE_PATH/data/mappers/${FILE_NAME_LOWER}.mapper.ts
touch $BASE_PATH/data/dtos/${FILE_NAME_LOWER}.dto.ts
touch $BASE_PATH/domain/repositories/${FILE_NAME_LOWER}.repository.ts
touch $BASE_PATH/domain/entities/${FILE_NAME_LOWER}.entity.ts
touch $BASE_PATH/domain/hooks/${FILE_NAME_LOWER}.hook.ts

# Generate base content for each file
echo "import endpoints from '@/core/constants/endpoints';
import request from '@/core/config/api';
import methods from '@/core/constants/methods';
import type { ${FILE_NAME_PASCALE}RequestDto, ${FILE_NAME_PASCALE}ResponseDto } from '../dtos/${FILE_NAME_LOWER}.dto';

class ${FILE_NAME_PASCALE}Api {
  constructor(private readonly ${FILE_NAME_LOWER}BaseUrl: string = endpoints.${FILE_NAME_LOWER}) {}

  // Define your API methods here
}

export default ${FILE_NAME_PASCALE}Api;" > $BASE_PATH/data/datasources/${FILE_NAME_LOWER}.api.ts

echo "import type { ${FILE_NAME_PASCALE}Repository } from '../../domain/repositories/${FILE_NAME_LOWER}.repository';
import type { ${FILE_NAME_PASCALE}Entity } from '../../domain/entities/${FILE_NAME_LOWER}.entity';
import ${FILE_NAME_PASCALE}Api from '../datasources/${FILE_NAME_LOWER}.api';
import ${FILE_NAME_PASCALE}Mapper from '../mappers/${FILE_NAME_LOWER}.mapper';

class ${FILE_NAME_PASCALE}RepositoryImpl implements ${FILE_NAME_PASCALE}Repository {
  constructor(
    private readonly ${FILE_NAME_LOWER}Api: ${FILE_NAME_PASCALE}Api = new ${FILE_NAME_PASCALE}Api(),
    private readonly ${FILE_NAME_LOWER}Mapper: ${FILE_NAME_PASCALE}Mapper = new ${FILE_NAME_PASCALE}Mapper(),
  ) {}

  // Define your repository methods here
}

export default ${FILE_NAME_PASCALE}RepositoryImpl;" > $BASE_PATH/data/repositories/${FILE_NAME_LOWER}.repository.impl.ts

echo "import type { ${FILE_NAME_PASCALE}Entity } from '../../domain/entities/${FILE_NAME_LOWER}.entity';
import type { ${FILE_NAME_PASCALE}ResponseDto } from '../dtos/${FILE_NAME_LOWER}.dto';

class ${FILE_NAME_PASCALE}Mapper {
  toEntity(dto: ${FILE_NAME_PASCALE}ResponseDto): ${FILE_NAME_PASCALE}Entity {
    return {
        // Map fields from dto to entity here
    };
  }
}

export default ${FILE_NAME_PASCALE}Mapper;" > $BASE_PATH/data/mappers/${FILE_NAME_LOWER}.mapper.ts

echo "export interface ${FILE_NAME_PASCALE}RequestDto {
  // Define the properties of the ${FILE_NAME_PASCALE}RequestDto here
}

export interface ${FILE_NAME_PASCALE}ResponseDto {
    // Define the properties of the ${FILE_NAME_PASCALE}ResponseDto here
}" > $BASE_PATH/data/dtos/${FILE_NAME_LOWER}.dto.ts

echo "import type { ${FILE_NAME_PASCALE}Entity } from '../entities/${FILE_NAME_LOWER}.entity';

export interface ${FILE_NAME_PASCALE}Repository {
    // Define the methods for the ${FILE_NAME_PASCALE}Repository here
}" > $BASE_PATH/domain/repositories/${FILE_NAME_LOWER}.repository.ts

echo "export interface ${FILE_NAME_PASCALE}Entity {
  // Define the properties of the ${FILE_NAME_PASCALE}Entity here
}" > $BASE_PATH/domain/entities/${FILE_NAME_LOWER}.entity.ts

echo "Files created successfully: $FILE_NAME_PASCAL"