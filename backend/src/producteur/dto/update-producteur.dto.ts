import { PartialType } from '@nestjs/swagger';
import { CreateProducteurDto } from './create-producteur.dto';

export class UpdateProducteurDto extends PartialType(CreateProducteurDto) {}
